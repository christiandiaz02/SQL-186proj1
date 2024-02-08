-- Before running drop any existing views
DROP VIEW IF EXISTS q0;
DROP VIEW IF EXISTS q1i;
DROP VIEW IF EXISTS q1ii;
DROP VIEW IF EXISTS q1iii;
DROP VIEW IF EXISTS q1iv;
DROP VIEW IF EXISTS q2i;
DROP VIEW IF EXISTS q2ii;
DROP VIEW IF EXISTS q2iii;
DROP VIEW IF EXISTS q3i;
DROP VIEW IF EXISTS q3ii;
DROP VIEW IF EXISTS q3iii;
DROP VIEW IF EXISTS q4i;
DROP VIEW IF EXISTS q4ii;
DROP VIEW IF EXISTS q4iii;
DROP VIEW IF EXISTS q4iv;
DROP VIEW IF EXISTS q4v;

-- Question 0
CREATE VIEW q0(era)
AS
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people AS P
  WHERE P.weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT namefirst, namelast, birthyear
  FROM people AS P
  WHERE INSTR(P.namefirst, ' ') > 0
  ORDER BY namefirst ASC, namelast ASC
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people AS P
  GROUP BY P.birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthyear, AVG(height), COUNT(*)
  FROM people as P
  GROUP BY P.birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT people.nameFirst, people.nameLast, people.playerID, HallOfFame.yearID
  FROM people
  INNER JOIN HallOfFame ON
  people.playerID=HallOfFame.playerID
  WHERE HallOfFame.inducted = 'Y'
  ORDER BY HallOfFame.yearID DESC, HallOfFame.playerID ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  SELECT people.nameFirst, people.nameLast, people.playerID, CollegePlaying.schoolID, HallOfFame.yearID
  FROM people
  INNER JOIN CollegePlaying ON
  people.playerID=CollegePlaying.playerID
  INNER JOIN HallOfFame ON
  people.playerID = HallOfFame.playerID
  INNER JOIN schools ON
  schools.schoolID = CollegePlaying.schoolID
  WHERE HallOfFame.inducted = 'Y' AND schools.schoolState = 'CA'
  ORDER BY HallOfFame.yearID DESC, schools.schoolID, people.playerID ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  SELECT people.playerID, people.nameFirst, people.nameLast, CollegePlaying.schoolID
  FROM people
  INNER JOIN HallOfFame ON
  people.playerID=HallOfFame.playerID
  LEFT JOIN CollegePlaying ON
  people.playerID=CollegePlaying.playerID
  WHERE HallOfFame.inducted = 'Y'
  ORDER BY people.playerID DESC, CollegePlaying.schoolID ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  SELECT people.playerID, people.nameFirst, people.nameLast, batting.yearID,
  (((CAST(batting.h AS FLOAT) - (CAST(batting.h2b AS FLOAT) + CAST(batting.h3b AS FLOAT)
  + CAST(batting.hr AS FLOAT))) + 2 * CAST(batting.h2b AS FLOAT) +
  3 * CAST(batting.h3b AS FLOAT) + 4 * CAST(batting.hr AS FLOAT))
  / CAST(batting.ab AS FLOAT)) AS slg
  FROM people
  INNER JOIN batting ON
  people.playerID=batting.playerID
  WHERE batting.ab > 50
  ORDER BY slg DESC, batting.yearID, people.playerID ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  SELECT people.playerID, people.nameFirst, people.nameLast,
  (((CAST(SUM(batting.h) AS FLOAT) - (CAST(SUM(batting.h2b) AS FLOAT) + CAST(SUM(batting.h3b)AS FLOAT)
  + CAST(SUM(batting.hr) AS FLOAT))) + 2 * CAST(SUM(batting.h2b) AS FLOAT) +
  3 * CAST(SUM(batting.h3b) AS FLOAT) + 4 * CAST(SUM(batting.hr) AS FLOAT))
  / CAST(SUM(batting.ab) AS FLOAT)) AS lslg
  FROM people
  INNER JOIN batting ON
  people.playerID=batting.playerID
  GROUP BY people.playerID
  HAVING CAST(SUM(batting.ab) AS FLOAT) > 50
  ORDER BY lslg DESC, people.playerID ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  SELECT people.nameFirst, people.nameLast,
  (((CAST(SUM(batting.h) AS FLOAT) - (CAST(SUM(batting.h2b) AS FLOAT) + CAST(SUM(batting.h3b)AS FLOAT)
  + CAST(SUM(batting.hr) AS FLOAT))) + 2 * CAST(SUM(batting.h2b) AS FLOAT) +
  3 * CAST(SUM(batting.h3b) AS FLOAT) + 4 * CAST(SUM(batting.hr) AS FLOAT))
  / CAST(SUM(batting.ab) AS FLOAT)) AS lslg
  FROM people
  INNER JOIN batting ON
  people.playerID=batting.playerID
  GROUP BY people.playerID
  HAVING CAST(SUM(batting.ab) AS FLOAT) > 50
  AND lslg >
  (
  SELECT (((CAST(SUM(batting.h) AS FLOAT) - (CAST(SUM(batting.h2b) AS FLOAT) +
  CAST(SUM(batting.h3b)AS FLOAT) + CAST(SUM(batting.hr) AS FLOAT))) + 2 *
  CAST(SUM(batting.h2b) AS FLOAT) + 3 * CAST(SUM(batting.h3b) AS FLOAT) +
  4 * CAST(SUM(batting.hr) AS FLOAT)) / CAST(SUM(batting.ab) AS FLOAT)) AS lslg
  FROM people
  INNER JOIN batting ON
  people.playerID = batting.playerID
  WHERE people.playerID='mayswi01'
  GROUP BY people.playerID
  )
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
  SELECT salaries.yearID, MIN(salaries.salary), MAX(salaries.salary), AVG(salaries.salary)
  FROM salaries
  GROUP BY salaries.yearID
  ORDER BY salaries.yearID ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  WITH bins AS (
          SELECT MIN(salary) AS low, MAX(salary) AS high,
          CAST (((MAX(salary) - MIN(salary))/10) AS INT) AS bin
          FROM salaries
          WHERE salaries.yearID = 2016
      )
      SELECT binid, low + binid * bin, low + (binid + 1) * bin, count(*)
      FROM binids, salaries, bins
      WHERE salary
      BETWEEN low + binid * bin
      AND low + (binid + 1) * bin
      AND salaries.yearID = 2016
      GROUP BY binid
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  WITH stats AS (
    SELECT salaries.yearID, MIN(salaries.salary) as min, MAX(salaries.salary) as max,
    AVG(salaries.salary) as avg
    FROM salaries
    GROUP BY salaries.yearID
  )
  SELECT b.yearID, b.min - a.min, b.max - a.max, b.avg - a.avg
  FROM stats as a
  INNER JOIN stats as b
  ON b.yearID = a.yearID + 1
  ORDER BY b.yearID ASC
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  WITH maxSalary AS (
    SELECT salaries.playerID, salaries.salary, salaries.yearID
    FROM salaries
    WHERE (salary = (SELECT MAX(salary) FROM salaries WHERE salaries.yearID = 2000)
    AND yearID = 2000)
    OR (salary = (SELECT MAX(salary) FROM salaries WHERE salaries.yearID = 2001
    AND yearID = 2001))
  )
  SELECT people.playerID, people.nameFirst, people.nameLast, maxSalary.salary, maxSalary.yearID
  FROM people
  INNER JOIN maxSalary
  ON maxSalary.playerID = people.playerID
  WHERE yearID = 2001 OR yearID = 2000
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  SELECT allstarfull.teamID, MAX(salaries.salary) - MIN(salaries.salary)
  FROM allstarfull
  INNER JOIN salaries
  ON salaries.yearID = allstarfull.yearID AND salaries.playerID = allstarfull.playerID
  WHERE salaries.yearID = 2016
  GROUP BY allstarfull.teamID
;

