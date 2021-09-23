#CREATE DATABASE vaje;

#ALTER DATABASE vaje CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE TABLE pleme (
    tid int,
    tribe varchar(10),
    PRIMARY KEY (tid)
);

CREATE TABLE aliansa (
    aid int,
    alliance varchar(30),
    PRIMARY KEY (aid)
);

CREATE TABLE igralec (
    pid int,
    player varchar(30),
    tid int,
    aid int,
    PRIMARY KEY (pid),
    FOREIGN KEY (tid) REFERENCES pleme(tid),
    FOREIGN KEY (aid) REFERENCES aliansa(aid)
);

CREATE TABLE  naselje (
    vid int,
    village varchar(30),
    x int,
    y int,
    population int,
    pid int,
    PRIMARY KEY (vid),
    FOREIGN KEY (pid) REFERENCES igralec(pid)
);

###########################################################

INSERT INTO pleme (tid, tribe)
VALUES 	(1,"Rimljani"),
		(2,"Tevtoni"),
		(3,"Galci"),
		(4,"Narava"),
		(5,"Natarji"),
		(6,"Huni"),
		(7,"Egipcani");

INSERT INTO aliansa (aid, alliance)  
SELECT DISTINCT aid, alliance
FROM x_world;

INSERT INTO	igralec (pid, player, tid, aid)
SELECT DISTINCT pid, player, tid, aid
FROM x_world;

INSERT INTO	naselje (vid, village, x, y, population, pid)
SELECT vid, village, x, y, population, pid
FROM x_world;

#SELECT * FROM igralec;

UPDATE igralec
SET aid = null
WHERE aid = 0;

SELECT * FROM aliansa;

DELETE FROM aliansa
WHERE aid = 0;

###########################################################

#a
SELECT player AS max_pop_nas
FROM igralec i, naselje n
WHERE i.pid = n.pid
AND n.population = (SELECT MAX(population)
	FROM naselje);

#b      
SELECT player AS max_st_nas
FROM igralec i, (SELECT pid, COUNT(pid) a
		FROM naselje
		GROUP BY pid
		ORDER BY COUNT(pid) DESC LIMIT 10) ppis
WHERE i.pid = ppis.pid
ORDER BY ppis.a DESC;

#c                 
SELECT COUNT(DISTINCT i.pid) AS nad_povp_nas
FROM igralec i, naselje n
WHERE i.pid = n.pid
AND n.population > (SELECT SUM(population) / COUNT(vid) as sest
					FROM naselje);

#d
SELECT n.vid, n. village, n.x, n.y, n.population, n.pid
FROM igralec i, naselje n
WHERE i.pid = n.pid 
AND aid IS null
ORDER BY x DESC, y DESC;

#e
SELECT tribe
FROM pleme
WHERE tid = (SELECT tid
			FROM naselje n, igralec i
			WHERE n.pid = i.pid
			AND tid IS NOT null
			GROUP BY tid
			ORDER BY SUM(population) DESC
			LIMIT 1);
            
#f
SELECT COUNT(aidd) as nad_povp_alianse
FROM(
SELECT COUNT(aid) as aidd
FROM igralec i, naselje n
WHERE i.pid = n.pid
AND aid IS NOT null
GROUP BY aid
HAVING SUM(population) > (SELECT SUM(population) / (SELECT COUNT(DISTINCT(aid)) from aliansa) as sest
						FROM naselje n, igralec i
						WHERE n.pid = i.pid
						AND aid IS NOT null)
) as tabela;

#g
DELIMITER //
CREATE PROCEDURE obmocje(in x0 int, in y0 int, in razdalja int)
BEGIN
	SELECT COALESCE(SUM(population), 0) AS sum_populacija
    FROM(
		SELECT population
        FROM naselje
        WHERE x >= x0 - razdalja AND x <= x0 + razdalja
        AND y >= y0 - razdalja AND y <= y0 + razdalja
    ) AS nekaj;
END //
DELIMITER ;

CALL obmocje(20, 60, 10);

#h
SELECT player
FROM igralec i,
(SELECT DISTINCT(prvi.pid)
FROM	(SELECT i.pid, COUNT(vid) as st
		FROM igralec i, naselje n
		WHERE i.pid = n.pid
		GROUP BY i.pid) prvi,

		(SELECT i.pid, COUNT(vid) as st
		FROM igralec i, naselje n
		WHERE i.pid = n.pid
		AND x BETWEEN 100 AND 200
		AND y BETWEEN 0 AND 100
		GROUP BY i.pid) drugi
WHERE prvi.pid = drugi.pid
AND prvi.st = drugi.st) ii
WHERE i.pid = ii.pid;

#i
SELECT DISTINCT(naselje.pid)
FROM naselje, (SELECT pid, SUM(population) as s
			FROM naselje 
			GROUP BY pid) pop,
			(SELECT i.pid, COUNT(vid) as st
			FROM igralec i, naselje n
			WHERE i.pid = n.pid
			GROUP BY i.pid) stnas
WHERE pop.pid = stnas.pid
AND naselje.pid = pop.pid
AND naselje.pid = stnas.pid
AND naselje.population < (pop.s / stnas.st) * 0.03;

#j
#Igralec »tempelis« zeli...

###########################################################

#DROP PROCEDURE UstvariAlianso;

DELIMITER //
CREATE PROCEDURE UstvariAlianso (
			in imeAlianse varchar(30),
            in a_pid int)
BEGIN
	INSERT INTO aliansa (aid, alliance)  
	VALUES ((SELECT MAX(aid)+1 FROM aliansa as a), imeAlianse);
    
    IF (SELECT aid FROM igralec WHERE pid = a_pid) IS null
    THEN
		UPDATE igralec
		SET aid = (SELECT MAX(aid) FROM aliansa)
		WHERE pid = a_pid;
    END IF;
END //
DELIMITER ;

CALL UstvariAlianso('Neznaniiii', 28);

#SELECT * FROM igralec;
#SELECT * FROM aliansa;

#UPDATE igralec
#SET aid = null
#WHERE pid = 289;

#DELETE FROM aliansa
#WHERE aid = 884;

START TRANSACTION;
INSERT INTO aliansa (aid, alliance)
VALUES ((SELECT MAX(aid)+1 FROM aliansa as a), "Virus™");
SET SQL_SAFE_UPDATES=0;
UPDATE igralec
SET aid = (SELECT aid FROM aliansa as b WHERE b.alliance = "Virus™")
WHERE aid = (SELECT aid FROM aliansa as c WHERE c.alliance = "GM-H4N1™")
OR aid = (SELECT aid FROM aliansa as d WHERE d.alliance = "RS-H3N3™");
COMMIT;

#SELECT * FROM aliansa WHERE alliance = "GM-H4N1™";
#SELECT * FROM igralec WHERE aid = 883;
#SELECT * FROM aliansa WHERE alliance = "RS-H3N3™";
#SELECT * FROM igralec WHERE aid = 640;