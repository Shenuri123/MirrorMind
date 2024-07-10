import uvicorn
import os
import librosa
from fastapi import FastAPI, UploadFile, File, HTTPException
from gensim.models import Word2Vec
from gensim.utils import simple_preprocess
from ultralytics import YOLO
from parameters import Parameter, NlpParameter, FunctionTwo, FunctionFour
import easyocr
import pandas as pd
from nltk.stem import WordNetLemmatizer
from keras.preprocessing.text import one_hot
from keras.utils import pad_sequences
from keras.models import load_model
from nltk.corpus import stopwords
import nltk
import pickle
import numpy as np
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import OneHotEncoder


app=FastAPI()
lemmatizer=WordNetLemmatizer()
stop_words = set(stopwords.words('english'))
nltk.download('punkt')
nltk.download('wordnet')
nltk.download('stopwords')


def preprocess_question_text(text,tokenizer,maxlen):
    words = nltk.word_tokenize(text)  # Tokenize the text into words
    words = [lemmatizer.lemmatize(word) for word in words]  # Lemmatize words
    words = [word for word in words if word.lower() not in stop_words]  # Remove stop words
    paragraph = ' '.join(words)
    with open(tokenizer, 'rb') as handle:
        loaded_tokenizer = pickle.load(handle)
    sequences = loaded_tokenizer.texts_to_sequences([paragraph])
    return pad_sequences(sequences, maxlen=maxlen)


def preprocess_text(text):
    voc_size=5000
    em_len=50
    text=simple_preprocess(text)
    word_list=[lemmatizer.lemmatize(word) for word in text if word not in stop_words]
    words = ' '.join(word_list)
    one_hot_rep= [one_hot(words,voc_size)]
    embeded_list=pad_sequences(one_hot_rep,padding='pre',maxlen=em_len)
    return embeded_list

def get_objects_in_img(path):
    obj_list=[]
    model = YOLO('yolov8m.pt')  # load a custom model
    # Predict with the model
    results = model(path, save=False, conf=0.4)
    for result in results:
        boxes = result.boxes.cpu().numpy()  # get boxes on cpu in numpy
        for box in boxes:  # iterate boxes
            r = box.xyxy[0].astype(int)  # get corner points as int
            obj_list.append(result.names[int(box.cls[0])])
    return obj_list

def get_text_in_img(path):
    reader = easyocr.Reader(['en'], gpu=True)
    result = reader.readtext(path)
    df = pd.DataFrame(result, columns=['boxes', 'text', 'threshold'])
    return ' '.join(df['text'])

def get_object_categories(objects):
    list_categories = ['negative', 'positive']
    object_category = []
    model = Word2Vec.load("my_model")
    
    for category in list_categories:
        for object in objects:
            # Check if the word is in the model's vocabulary
            if category in model.wv.key_to_index and object in model.wv.key_to_index:
                distance = model.wv.distance(category, object)
                if distance > 0.75:
                    object_category.append(category)
                    
    if len(object_category) == 0:
        return 'unknown'  # or some other default value
    elif object_category.count('negative') > len(object_category) // 2:
        return 'negative'
    else:
        return 'positive'



# Predict Emotion from Audio using LSTM Model
def predict_emotion_from_audio(audio_file_path):
    # Load the trained emotion recognition model
    model = load_model('src/fun1/final_LSTM_best_model.h5')

    # Load the encoder for emotion labels (replace with your encoder)
    # You need to load the same encoder that was used during model training
    # Define your emotion labels here (in the same order as used during training)
    emotion_labels = ['angry', 'disgust', 'fear', 'happy', 'neutral', 'sad', 'ps']
    enc = OneHotEncoder(sparse_output=False)
    enc.fit(np.array(emotion_labels).reshape(-1, 1))

    # Create a mapping from emotion labels to integers
    label_to_int = {label: i for i, label in enumerate(emotion_labels)}

    # Function to extract MFCC features from an audio segment
    def extract_mfcc(y, sr):
        mfcc = np.mean(librosa.feature.mfcc(y=y, sr=sr, n_mfcc=40).T, axis=0)
        return mfcc

    # Function to predict emotion for a single segment
    def predict_emotion(segment):
        # Extract MFCC features
        mfcc = extract_mfcc(segment, sampling_rate)
        
        # Reshape for model input
        mfcc = mfcc.reshape(1, mfcc.shape[0], 1)
        
        # Predict emotion
        emotion_probabilities = model.predict(mfcc)
        
        return emotion_probabilities

    # Split long audio into overlapping segments
    segment_length = 3  # Length of each segment in seconds
    overlap = 0.0  # Overlap between segments in seconds
    sampling_rate = 22050  # Replace with the appropriate sampling rate
    segments = []

    # Split the uploaded audio into overlapping segments
    y, _ = librosa.load(audio_file_path, sr=sampling_rate)
    for start in np.arange(0, len(y), int((segment_length - overlap) * sampling_rate)):
        end = int(start + segment_length * sampling_rate)
        segment = y[start:end]
        segments.append(segment)

    # Predict emotions for all segments
    emotion_predictions = []
    for segment in segments:
        emotion_probabilities = predict_emotion(segment)
        emotion_predictions.append(emotion_probabilities)

    # Convert aggregated probabilities to emotion labels for all segments
    emotion_labels_for_segments = [enc.inverse_transform(emotion_probabilities).flatten()[0] for emotion_probabilities in emotion_predictions]

    # Calculate the percentage of each emotion
    total_segments = len(emotion_labels_for_segments)
    emotion_percentages = {label: emotion_labels_for_segments.count(label) / total_segments * 100 for label in set(emotion_labels_for_segments)}

    # Return the emotions and their percentages
    emotions_and_percentages = {emotion: percentage for emotion, percentage in emotion_percentages.items()}

    return emotions_and_percentages


@app.get('/')
def index():
    return {'message':'build successful'}

@app.post('/predict')
def get_prediction(data: Parameter):
    data = data.dict()
    path = data.get('img_path')  # Use the get method to safely access the key
    text = data.get('text')  # Use the get method to safely access the key

    if path is None or text is None:
        return {'error': 'img_path and text are required fields'}

    objects = get_objects_in_img(path)
    img_text = get_text_in_img(path)
    img_category_objects = get_object_categories(objects)

    return {'objects': objects, 'img_text': img_text}



@app.post('/funone')
def question_result(audio_file: UploadFile, text: str):
    # Text processing and result prediction
    model = load_model('src/fun1/question_model.h5')
    X_test = preprocess_question_text(text, 'src/fun1/question_tokenizer.pickle', 150)
    pred = model.predict(X_test)
    levels = ['mild', 'minimal', 'moderate', 'severe']
    question_result = levels[np.argmax(pred)]

    # Save the uploaded audio file
    audio_file_path = f"uploaded_audio/{audio_file.filename}"
    with open(audio_file_path, "wb") as f:
        f.write(audio_file.file.read())

    # Predict emotions from audio
    emotions_and_percentages = predict_emotion_from_audio(audio_file_path)

    # Clean up by removing the uploaded audio file
    os.remove(audio_file_path)

    return {'text_result': question_result, 'emotions_percentages': emotions_and_percentages}


@app.post('/funtwo')
def functionTwo(content:FunctionTwo):
    content = content.dict()
    text_results=[]
    image_results=[]
    emotion_dict={'happy':-0.25,'neutral':0,'sad':0.25}
    model = load_model('src/fun2/function2_quiz_model.h5')
    for i in range(1,5):
        text=content[f'text{i}']
        X_test=preprocess_question_text(text,'src/fun2/tokenizer.pickle',25)
        result = model.predict(X_test)
        text_results.append(result)
        img = content[f'img{i}']
        image_results.append(emotion_dict[img])
    text_results_int = list(map(int, text_results))

    result_list=[x+y for x,y in zip(text_results_int,image_results)]
    result=sum(result_list)/4
    return {'percentage':f"{result}"}


@app.post('/funthree')
def get_nlp_prediction(data:NlpParameter):
    data = data.dict()
    text = data['text']
    model = load_model('src/fun3/nlp_model.h5')
    pred = model.predict(preprocess_text(text))
    result='You are dipressed!' if pred>0.5 else 'You are not dipressed!'
    return {'score': str(pred),'result':result}


@app.post('/funfour')
def game_predict(data:FunctionFour):
    data = data.dict()
    model = LinearRegression()
    # X = np.array([1, 2, 3, 4, 5]).reshape(-1, 1)  # Reshape to a column vector
    # y = np.array([5, 9, 3, 6, 2])
    X = np.array(data['x']).reshape(-1, 1)  # Reshape to a column vector
    y = np.array(data['y'])
    model.fit(X, y)
    slope = model.coef_[0]
    if slope<0:
        return {'level': 'Depression decreasing'}
    else:
        return {'level': 'Depression increasing'}


if __name__=='__main__':
    uvicorn.run(app,host='127.0.0.1',port=8000)


# P:\SilverlineIT\mirror-mind\git\MirrorMind-ML\Machine learning\API
# uvicorn app:app --reload
# 'P:\\SilverlineIT\\mirror-mind\\git\\MirrorMind-ML\\Machine learning\\function 3\\img.png'

