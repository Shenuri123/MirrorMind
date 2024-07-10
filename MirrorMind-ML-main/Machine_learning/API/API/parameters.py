from pydantic import BaseModel
from fastapi import File, UploadFile

class Parameter(BaseModel):
    img_path:str
    text:str


class NlpParameter(BaseModel):
    text:str


class FunctionTwo(BaseModel):
    img1: str   # img1:UploadFile = File(...)
    text1:str
    img2: str
    text2: str
    img3: str
    text3: str
    img4: str
    text4: str

class FunctionFour(BaseModel):
    y:list
    x:list