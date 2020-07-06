set checkForeignKeys {PRAGMA FOREIGN_KEYS = True}
set constraintsStructList {
    {
        {FOREIGN KEY constraint failed} False


        {1.01 Insert with wrong topic}
        {
            INSERT INTO toDos
            (description, mainTopicID)
            VALUES
            ('Niet bestaand topic', 999999)
            ;
        }

        {1.04 Update to wrong topic}
        {UPDATE toDos SET mainTopicID = 999999 WHERE toDoID = 1}

        {1.05 Delete while still refered from toDosTopics}
        {DELETE FROM toDos WHERE toDoID = 1}

        {2.02 Delete used in toDos}
        {DELETE FROM topics WHERE topicID = 1;}

        {2.03 Delete used in toDosTopics}
        {DELETE FROM topics WHERE topicID = 3;}

        {2.04 Update id used in toDos}
        {UPDATE topics SET topicID = 7 WHERE topicID = 1;}

        {2.05 Update id used in toDosTopics}
        {UPDATE topics SET topicID = 7 WHERE topicID = 5;}

        {3.01 Insert with wrong toDoID}
        {
            INSERT INTO toDosTopics
            VALUES
            (999999, 1)
            ;
        }

        {3.02 Insert with wrong topicID}
        {
            INSERT INTO toDosTopics
            VALUES
            (1, 999999)
            ;
        }

        {3.05 Update used to wrong toDoID}
        {UPDATE toDosTopics SET toDoID = 999999 WHERE toDoID = 1 AND topicID = 3;}

        {3.06 Update used to wrong toDoID}
        {UPDATE toDosTopics SET topicID = 999999 WHERE toDoID = 1 AND topicID = 3;}
    }

    {
        {Cannot set Main Topic as Non Main Topic} False


        {3.03 Insert with main topic}
        {
            INSERT INTO toDosTopics
            VALUES
            (1, 1)
            ;
        }

        {3.07 Update to main topic}
        {UPDATE toDosTopics SET topicID = 1 WHERE toDoID = 1 AND topicID = 3;}
    }

    {
        {Cannot set Non Main Topic as Main Topic} False


        {1.03 Update main topic to a non main topic}
        {UPDATE toDos SET mainTopicID = 3 WHERE toDoID = 1}
    }

    {
        {UNIQUE constraint failed: } True


        {1.02 Insert duplicate todo}
        {
            INSERT INTO toDos
            (description, mainTopicID)
            VALUES
            ('Soliciteren', 3)
            ;
        }

        {2.01 Insert duplicate}
        {
            INSERT INTO topics
            (name)
            VALUES
            ('Werk')
            ;
        }

        {3.04 Insert already used topic}
        {
            INSERT INTO toDosTopics
            VALUES
            (1, 3)
            ;
        }

        {3.08 Update to already used topic}
        {UPDATE toDosTopics SET topicID = 5 WHERE toDoID = 1 AND topicID = 3;}
    }
}
set createToDos {
    CREATE TABLE toDos (
        toDoID      INTEGER PRIMARY KEY,
        description TEXT    NOT NULL COLLATE NOCASE UNIQUE,
        mainTopicID INTEGER NOT NULL REFERENCES topics(topicID)
    );
    CREATE INDEX toDoTopic ON toDos(mainTopicID);
}
set createToDosTopics {
    CREATE TABLE toDosTopics (
        toDoID    INTEGER NOT NULL REFERENCES toDos(toDoID),
        topicID   INTEGER NOT NULL REFERENCES topics(topicID),

        PRIMARY KEY (toDoID,  topicID),
        UNIQUE      (topicID, toDoID)
    ) WITHOUT ROWID;
}
set createTopics {
    CREATE TABLE topics (
        topicID INTEGER PRIMARY KEY,
        name    TEXT    NOT NULL COLLATE NOCASE UNIQUE
    );
}
set createTriggers {
    CREATE TRIGGER TTI BEFORE INSERT ON toDosTopics
    BEGIN
        SELECT RAISE(ABORT, 'Cannot set Main Topic as Non Main Topic')
        WHERE new.topicID == (
            SELECT mainTopicID
            FROM toDos
            WHERE toDos.todoID == new.todoID
        );
    END;
    CREATE TRIGGER TTU BEFORE UPDATE ON toDosTopics
    BEGIN
        SELECT RAISE(ABORT, 'Cannot set Main Topic as Non Main Topic')
        WHERE new.topicID == (
            SELECT mainTopicID
            FROM   toDos
            WHERE  toDos.toDoID == new.toDoID
        );
    END;
    CREATE TRIGGER TU BEFORE UPDATE ON toDos
    BEGIN
        SELECT RAISE(ABORT, 'Cannot set Non Main Topic as Main Topic')
        WHERE  0 < (
            SELECT COUNT(*)
            FROM   toDosTopics
            WHERE  toDosTopics.toDoID  = new.toDoID
               AND toDosTopics.topicID = new.mainTopicID
        );
    END;
}
set createViews {
    CREATE   VIEW toDosView AS
        SELECT   toDos.toDoID
        ,        toDos.description
        ,        topics.name
        FROM     toDos
        ,        topics
        WHERE    toDos.mainTopicID = topics.topicID
        ;
    CREATE   VIEW toDosTopicsView AS
        SELECT   toDos.description
        ,        topics.name
        FROM     toDosTopics
        ,        toDos
        ,        topics
        WHERE    toDosTopics.toDoID  = toDos.toDoID
             AND toDosTopics.topicID = topics.topicID
        ;
}
set database ~/Databases/testing.sqlite
set dropTablesAndViews {
    DROP VIEW  IF EXISTS toDosTopicsView;
    DROP VIEW  IF EXISTS toDosView;
    DROP TABLE IF EXISTS toDosTopics;
    DROP TABLE IF EXISTS toDos;
    DROP TABLE IF EXISTS topics;
}
set insertToDos  {
    INSERT INTO toDos
    (description, mainTopicID)
    VALUES
    ('Soliciteren',         1)
    ;
}
set insertToDosTopics {
    INSERT INTO toDosTopics
    VALUES
    (1, 3),
    (1, 5)
    ;
}
set insertTopics {
    INSERT INTO topics
    (name)
    VALUES
    ('Werk'),
    ('Financiën'),
    ('Familie'),
    ('Vrienden'),
    ('Hobbies'),
    ('ToastMasters')
    ;
}
