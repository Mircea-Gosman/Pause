from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from Database.Database import Base  # Remove Database. when instantiating database with shell, add for runtime

class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)
    key = Column(Integer, nullable=False, unique=True)
    days = relationship('Day', backref='user', lazy=True)

class Day(Base):
    __tablename__ = 'days'
    id = Column(Integer, primary_key=True)
    userID = Column(Integer, ForeignKey('users.id'), nullable=False)
    courses = relationship('Course', backref='day', lazy=True)

class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True)
    start = Column(String, nullable=False)
    end = Column(String, nullable=False)
    text = Column(String, nullable=False)
    weekDay = Column(Integer, ForeignKey('days.id'), nullable=False)

# One to many relationship reference : https://www.youtube.com/watch?v=juPQ04_twtA  Pretty Printed Yt channel
