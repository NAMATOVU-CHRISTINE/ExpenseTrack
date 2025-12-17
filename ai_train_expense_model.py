# AI Expense Categorization Model Trainer
# Usage: Run this script to train and save a model for expense categorization.
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sklearn.model_selection import train_test_split
from joblib import dump

# Example: Load your labeled data (replace with your actual data source)
data = pd.read_csv('expense_training_data.csv')  # columns: description, vendor, category

# Combine description and vendor for better context
X = data['description'].fillna('') + ' ' + data['vendor'].fillna('')
y = data['category']

# Split for validation (optional)
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.1, random_state=42)

# Build pipeline
model = Pipeline([
    ('tfidf', TfidfVectorizer()),
    ('clf', MultinomialNB()),
])

# Train
model.fit(X_train, y_train)

# Save model
MODEL_PATH = 'expense_category_model.joblib'
dump(model, MODEL_PATH)
print(f"Model trained and saved to {MODEL_PATH}")

# Optional: Evaluate
score = model.score(X_test, y_test)
print(f"Validation accuracy: {score:.2%}")
