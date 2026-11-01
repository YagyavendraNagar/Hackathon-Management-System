from fastapi import FastAPI
from database import get_connection

app = FastAPI(title="Hackathon Management System")


@app.get("/")
def home():
    return {
        "message": "Hackathon Management System Backend is Running!"
    }


@app.get("/test-db")
def test_database():
    connection = get_connection()

    if connection.is_connected():
        connection.close()
        return {
            "message": "MySQL database connected successfully!"
        }

    return {
        "message": "Database connection failed!"
    }


@app.get("/participants")
def get_participants():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("SELECT * FROM participant")

    participants = cursor.fetchall()

    cursor.close()
    connection.close()

    return participants




@app.get("/teams")
def get_teams():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            t.team_id,
            t.team_name,
            h.name AS hackathon_name
        FROM team t
        JOIN hackathon h
            ON t.hackathon_id = h.hackathon_id
    """)

    teams = cursor.fetchall()

    cursor.close()
    connection.close()

    return teams


@app.get("/projects")
def get_projects():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            p.project_id,
            p.title AS project_name,
            t.team_name,
            p.technology
        FROM project p
        JOIN team t
            ON p.team_id = t.team_id
    """)

    projects = cursor.fetchall()

    cursor.close()
    connection.close()

    return projects


@app.get("/leaderboard")
def get_leaderboard():
    connection = get_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT
            p.title AS project_name,
            t.team_name,
            AVG(
                e.innovation_score +
                e.technical_score +
                e.presentation_score
            ) AS average_score
        FROM project p
        JOIN team t
            ON p.team_id = t.team_id
        JOIN evaluation e
            ON p.project_id = e.project_id
        GROUP BY p.project_id, p.title, t.team_name
        ORDER BY average_score DESC
    """)

    leaderboard = cursor.fetchall()

    cursor.close()
    connection.close()

    return leaderboard


@app.post("/participants")
def add_participant(
    name: str,
    email: str,
    college: str,
    phone: str
):
    connection = get_connection()
    cursor = connection.cursor()

    query = """
        INSERT INTO participant
        (name, email, college, phone)
        VALUES (%s, %s, %s, %s)
    """

    values = (name, email, college, phone)

    cursor.execute(query, values)
    connection.commit()

    cursor.close()
    connection.close()

    return {
        "message": "Participant added successfully!"
    }
    
    
@app.delete("/participants/{participant_id}")
def delete_participant(participant_id: int):
    connection = get_connection()
    cursor = connection.cursor()

    cursor.execute(
        "DELETE FROM participant WHERE participant_id = %s",
        (participant_id,)
    )

    connection.commit()

    cursor.close()
    connection.close()

    return {
        "message": "Participant deleted successfully!"
    }
    
@app.put("/participants/{participant_id}")
def update_participant(
    participant_id: int,
    name: str,
    email: str,
    college: str,
    phone: str
):
    connection = get_connection()
    cursor = connection.cursor()

    query = """
        UPDATE participant
        SET name = %s,
            email = %s,
            college = %s,
            phone = %s
        WHERE participant_id = %s
    """

    values = (name, email, college, phone, participant_id)

    cursor.execute(query, values)
    connection.commit()

    cursor.close()
    connection.close()

    return {
        "message": "Participant updated successfully!"
    }
    
@app.post("/teams")
def add_team(
    team_name: str,
    hackathon_id: int
):
    connection = get_connection()
    cursor = connection.cursor()


    query = """
        INSERT INTO team
        (team_name, hackathon_id)
        VALUES (%s, %s)
    """

    values = (team_name, hackathon_id)

    cursor.execute(query, values)
    connection.commit()

    cursor.close()
    connection.close()

    return {
        "message": "Team added successfully!"
    }
    
@app.post("/projects")
def add_project(
    team_id: int,
    title: str,
    description: str,
    technology: str
):
    connection = get_connection()
    cursor = connection.cursor()

    query = """
        INSERT INTO project
        (team_id, title, description, technology)
        VALUES (%s, %s, %s, %s)
    """

    values = (team_id, title, description, technology)

    cursor.execute(query, values)
    connection.commit()

    cursor.close()
    connection.close()

    return {
        "message": "Project added successfully!"
    }
    

   