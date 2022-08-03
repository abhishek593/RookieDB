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
  SELECT MAX(ERA) from PITCHING;
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear FROM PEOPLE WHERE weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  SELECT nameFirst, nameLast, birthYear FROM PEOPLE WHERE nameFirst LIKE '% %' ORDER BY
  nameFirst, nameLast
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height), COUNT(*) FROM PEOPLE GROUP BY birthYear ORDER BY birthYear
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  SELECT birthYear, AVG(height), COUNT(*) FROM PEOPLE GROUP BY birthYear HAVING AVG(height) > 70 ORDER BY birthYear
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  SELECT namefirst, nameLast, P.playerid, H.yearid FROM PEOPLE P INNER JOIN HALLOFFAME H ON P.playerid=H.playerid WHERE H.inducted='Y' ORDER BY H.yearid
  DESC, P.playerid ASC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
    SELECT nameFirst, nameLast, CP.playerid as playerid, CP.schoolid as schoolid, H.yearid as yearid from PEOPLE P, COLLEGEPLAYING CP, SCHOOLS S, HALLOFFAME H
    WHERE P.playerid=CP.playerid AND CP.schoolid=S.schoolid AND H.playerid=CP.playerid AND H.inducted='Y' AND S.schoolState='CA'
    ORDER BY yearid DESC, schoolid, playerid
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
    WITH X AS (SELECT P.playerid, nameFirst, nameLast FROM PEOPLE P INNER JOIN HALLOFFAME H ON P.playerid=H.playerid AND H.inducted='Y')
    SELECT X.playerid, X.nameFirst, X.nameLast, CP.schoolid FROM X LEFT OUTER JOIN COLLEGEPLAYING CP ON X.playerid=CP.playerid
    ORDER BY X.playerid DESC, CP.schoolid
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
    SELECT P.playerid, nameFirst, nameLast, B.yearid, cast(B.H + B.H2B + 2 * B.H3B + 3 * B.HR as real) / B.AB as slg
    FROM PEOPLE P INNER JOIN BATTING B ON P.playerid=B.playerid WHERE B.AB > 50 ORDER BY slg DESC LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
    WITH B AS (SELECT playerid, SUM(H) AS H, SUM(H2B) AS H2B, SUM(H3B) AS H3B, SUM(HR) AS HR, SUM(AB) AS AB FROM BATTING GROUP BY playerid)
    SELECT P.playerid, nameFirst, nameLast, cast(B.H + B.H2B + 2 * B.H3B + 3 * B.HR as real) / B.AB as lslg
    FROM PEOPLE P INNER JOIN B ON P.playerid=B.playerid WHERE B.AB > 50 ORDER BY lslg DESC, P.playerid LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
    WITH B AS (SELECT playerid, SUM(H) AS H, SUM(H2B) AS H2B, SUM(H3B) AS H3B, SUM(HR) AS HR, SUM(AB) AS AB FROM BATTING GROUP BY playerid)
    SELECT nameFirst, nameLast, cast(B.H + B.H2B + 2 * B.H3B + 3 * B.HR as real) / B.AB as lslg FROM PEOPLE P INNER JOIN B
    ON P.playerid=B.playerid WHERE B.AB > 50 AND
    lslg > (SELECT cast(B.H + B.H2B + 2 * B.H3B + 3 * B.HR as real) / B.AB FROM B WHERE B.playerid='mayswi01')
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg)
AS
    SELECT yearid, MIN(salary), MAX(salary), AVG(salary) FROM SALARIES GROUP BY yearid ORDER BY yearid
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
    WITH X AS (SELECT MIN(salary) AS MINI, MAX(salary) - MIN(salary) AS GAP FROM SALARIES WHERE yearid=2016),
    Y AS (SELECT binid, X.MINI + CAST (X.GAP / 10 AS INT) * binid AS LOW, X.MINI + CAST (X.GAP / 10 AS INT) * (binid + 1) AS HIGH FROM binids, X)
    SELECT Y.binid, Y.LOW, Y.HIGH, (SELECT COUNT(*) FROM SALARIES S WHERE S.yearid=2016 AND S.SALARY >= Y.LOW
    AND CASE WHEN Y.binid=9 THEN S.SALARY <= Y.HIGH ELSE S.SALARY < Y.HIGH END) FROM Y
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
    WITH Y AS (SELECT yearid, MIN(salary) as MIN_SAL, MAX(salary) AS MAX_SAL, AVG(salary) AS AVG_SAL FROM SALARIES GROUP BY yearid ORDER BY yearid)
    SELECT X.yearid, X.MIN_SAL - Y.MIN_SAL, X.MAX_SAL - Y.MAX_SAL, X.AVG_SAL - Y.AVG_SAL FROM Y X, Y WHERE X.yearid = Y.yearid + 1
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
    WITH X AS (SELECT playerid, yearid, MAX(SALARY) as MAX_SAL FROM SALARIES WHERE yearid = 2000 OR yearid = 2001 GROUP BY yearid ORDER BY yearid)
    SELECT P.playerid, nameFirst, nameLast, X.MAX_SAL, X.yearid FROM PEOPLE P INNER JOIN X ON P.playerid=X.playerid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
    WITH X AS (SELECT A.teamID AS teamID, S.salary AS salary FROM SALARIES S INNER JOIN ALLSTARFULL A ON S.playerid=A.playerid AND
    A.yearid=2016 AND S.yearid=2016)
    SELECT teamID, MAX(salary) - MIN(salary) FROM X GROUP BY teamID;
;

