from gensim.models import Word2Vec
from gensim import downloader

# Load a pre-trained model
model_pre = downloader.load('word2vec-google-news-300')

# custom corpus
sentences = [["cat", "say", "meow"], ["dog", "say", "woof"]]
# Train a Word2Vec model
model = Word2Vec(sentences, min_count=1)
# Save the model
model.save("my_model")
# Load the model
model_train = Word2Vec.load("my_model")

# Calculate the distance between two words
def distance_between_words(model,word1, word2):
    distance = model.wv.distance(word1, word2)
    return distance
    # else:
    #     return "One or both words not in vocabulary"

# Test the function
print(distance_between_words(model_pre,'king', 'queen'))
# print(distance_between_words(model_train,'cat', 'dog'))
