# -----------------------------------------------------------
# Definition of the database
#
# 2020 Mircea Gosman, Terrebonne, Canada
# email mirceagosman@gmail.com
# -----------------------------------------------------------
from sqlalchemy import Table, Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship
from Database.Database import Base  # Remove Database. when instantiating database with shell, add for runtime


# Friend connection tables
friendConnections = Table('friends', Base.metadata,
    Column('user1', Integer, ForeignKey('users.id'), nullable=False),  # Current user db ID
    Column('user2', Integer, ForeignKey('users.id'), nullable=False)   # Friend db ID
)

# Users table
class User(Base):
    __tablename__ = 'users'
    id = Column(Integer, primary_key=True)                              # user db ID
    key = Column(Integer, nullable=False, unique=True)                  # Facebook ID
    days = relationship('Day', backref='user', lazy=True)               # link to days table
    friends = relationship('User', secondary=friendConnections,         # link to friends table
                    primaryjoin=id==friendConnections.c.user1,
                    secondaryjoin=id==friendConnections.c.user2,
                    backref='friendConnections',
                    lazy=True
    )

# Days table
class Day(Base):
    __tablename__ = 'days'
    id = Column(Integer, primary_key=True)                              # day db ID
    title = Column(String, nullable=False)                              # title
    userID = Column(Integer, ForeignKey('users.id'), nullable=False)    # user id
    courses = relationship('Course', backref='day', lazy=True)          # courses id

# Courses table
class Course(Base):
    __tablename__ = 'courses'
    id = Column(Integer, primary_key=True)                              # course db ID
    start = Column(String, nullable=False)                              # start time string
    end = Column(String, nullable=False)                                # end time string
    text = Column(String, nullable=False)                               # content string
    weekDay = Column(Integer, ForeignKey('days.id'), nullable=False)    # title string


# One to many relationship reference : https://www.youtube.com/watch?v=juPQ04_twtA  Pretty Printed Yt channel
