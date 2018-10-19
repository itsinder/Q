
# coding: utf-8

# In[12]:


import sklearn_dt_utils as utils
from sklearn.tree import export_graphviz
import pandas as pd
import os


# In[13]:


q_src_dir = os.getenv('Q_SRC_ROOT')
if not q_src_dir:
    print("'Q_SRC_ROOT' is not set")
    exit(-1)
train_csv_file_path = "%s/ML/KNN/data/titanic/titanic_train_train.csv"  % q_src_dir
test_csv_file_path = "%s/ML/KNN/data/titanic/titanic_train_test.csv"  % q_src_dir
graphviz_gini = "graphviz_gini.txt"
graphviz_entropy = "graphviz_entropy.txt"
goal_col_name = "Survived"


# In[14]:


print("Train data shape")
train_data = utils.import_data(train_csv_file_path)
print("Test data shape")
test_data = utils.import_data(test_csv_file_path)


# In[15]:


X, Y, X_train, temp_X_train, y_train, temp_y_train = utils.split_dataset(train_data, goal_col_name, 1)
X_train = pd.concat([X_train, temp_X_train])
y_train = pd.concat([y_train, temp_y_train])
X, Y, X_test, temp_X_test, y_test, temp_y_test = utils.split_dataset(test_data, goal_col_name, 1)
X_test = pd.concat([X_test, temp_X_test])
y_test = pd.concat([y_test, temp_y_test])


# In[16]:


#print(len(X_train))
#print(len(X_test))


# In[17]:


# cross validation
# cross_validate_dt_new(X, Y)


# In[18]:


# cross validation
# cross_validate_dt(X, Y)


# In[19]:


# Train using gini
clf_gini = utils.train_using_gini(X_train, y_train)
# print(X_train[1])
export_graphviz(clf_gini, out_file=graphviz_gini, filled=True, rounded=True, special_characters=True, feature_names=X_train.columns)


# In[20]:


# Prediction using gini
y_pred_gini = utils.prediction(X_test, clf_gini)
print("Results for gini algo")
utils.cal_accuracy(y_test, y_pred_gini)


# In[21]:


# Train using entropy
clf_entropy = utils.tarin_using_entropy(X_train, y_train)
# print(clf_entropy)
utils.export_graphviz(clf_entropy, out_file=graphviz_entropy)


# In[22]:


# Prediction using entropy
y_pred_entropy = utils.prediction(X_test, clf_entropy)
print("Results for entropy algo")
utils.cal_accuracy(y_test, y_pred_entropy)

