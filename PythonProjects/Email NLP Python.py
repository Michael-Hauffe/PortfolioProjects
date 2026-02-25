#Importing libraries
import pandas as pd
#Text feature extraction
from sklearn.feature_extraction.text import TfidfVectorizer
#Import models
from sklearn.svm import SVC
from sklearn.svm import LinearSVC
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
#Import libraries for cross validation, splitting the data into train and test sets, and for the pipeline
from sklearn.model_selection import RandomizedSearchCV
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import FunctionTransformer
from sklearn.pipeline import Pipeline
#Import preprocessing libraries and download used files
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem.snowball import SnowballStemmer
nltk.download('punkt_tab')
nltk.download('stopwords')
stemmer = SnowballStemmer("english")
english_stopwords = stopwords.words("english")

#Import the dataset
EmailDataFilePath = r"C:\Users\Puter_Rabbit\Desktop\NLP Projects\EmailDataset.csv"
df = pd.read_csv(EmailDataFilePath)

#Viewing a sample of the data
print(df.head())

#We see significantly more Non-Spam, so I'll use balanced class_weights where available and f1_macro so both labels are equally considered
print(df["Label"].value_counts())

#Removes unhelpful stopwords from text
def remove_stopwords(tokens):
    return [word for word in tokens if word.lower() not in english_stopwords]

#Data cleaning function used in the pipeline
def cleandata(text):
    messagebody = text.apply(
        lambda text: [stemmer.stem(word) for word in word_tokenize(text)]
    )
    cleanedmessagebody = messagebody.apply(remove_stopwords).str.join(" ")
    return cleanedmessagebody
#Turning the cleandata() function into a transformer for use in the pipeline
cleaner = FunctionTransformer(cleandata,validate=False)

#Pipeline setup. Model placeholder allows RandomizedSearchCV to inject different models
pipeline = Pipeline(steps=[
    ("cleanup", cleaner),
    ("vectorizer", TfidfVectorizer(ngram_range=(1,5))),
    ("model",None)
])

param_grid = [{
    "model":[LinearSVC(class_weight="balanced",random_state=44)],
    "model__C":[0.1,1,10]},
{
    "model":[RandomForestClassifier(class_weight="balanced", random_state = 44)],
    "model__n_estimators":[10,50,100]},
{
    "model":[LogisticRegression(class_weight="balanced",random_state=44)],
    "model__C":[0.1,1,10]},
{
    "model":[SVC(class_weight="balanced",random_state=44)],
    "model__C":[0.1,1,10]}
]

#Randomized search for efficient runtime
Search = RandomizedSearchCV(estimator=pipeline,
                            param_distributions=param_grid,
                            scoring="f1_macro",
                            n_jobs=-1)

#Splitting into train and test sets
X_train, X_test, y_train, y_test = train_test_split(df["Message_body"], df["Label"], test_size=0.2,stratify=df["Label"])

#Fitting the model
Search.fit(X_train, y_train)

#Best model parameters
print(Search.best_params_)
#output: {'model__C': 1, 'model': LinearSVC(class_weight='balanced', random_state=44)}

#Best cross validation score
print(Search.best_score_)
#output: 0.95
