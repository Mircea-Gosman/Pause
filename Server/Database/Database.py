import os

from sqlalchemy import create_engine
from sqlalchemy.orm import scoped_session, sessionmaker
from sqlalchemy.ext.declarative import declarative_base


# Build the path
absPath = os.path.dirname(os.path.abspath(__file__))
semiFullPath = os.path.join(absPath, 'Store.db')
fullPath ='sqlite:///' + semiFullPath

# Create the session
engine = create_engine(fullPath, convert_unicode=True)
db_session = scoped_session(sessionmaker(autocommit=False,
                                         autoflush=False,
                                         bind=engine))
Base = declarative_base()
Base.query = db_session.query_property()

# Call from shell to create database file
def init_db():
    # import all modules here that might define models so that
    # they will be registered properly on the metadata.  Otherwise
    # you will have to import them first before calling init_db()
    import Models.Models
    Base.metadata.create_all(bind=engine)