-- Creating the database schema
CREATE SCHEMA greenFuture;
USE greenFutures;

-- Creating Members table
CREATE TABLE Members (
    MemberID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    ContactInfo VARCHAR(255),
    MembershipType ENUM('Basic', 'Silver', 'Gold'),
    ConservationInterests TEXT
);

-- Creating Staff table
CREATE TABLE Staff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Role VARCHAR(50),
    ContactInfo VARCHAR(255)
);

-- Creating Projects table
CREATE TABLE Projects (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(100),
    Description TEXT,
    Schedule DATE,
    MaxParticipants INT,
    StaffID INT,
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

-- Creating Bookings table
CREATE TABLE Bookings (
    BookingID INT AUTO_INCREMENT PRIMARY KEY,
    MemberID INT,
    ProjectID INT,
    BookingDate DATE,
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID),
    FOREIGN KEY (ProjectID) REFERENCES Projects(ProjectID)
);

-- Populating sample data
INSERT INTO Members (Name, ContactInfo, MembershipType, ConservationInterests)
VALUES 
('Michael Green', 'mailto:michaelgreen@example.com', 'Gold', 'Wildlife, Habitat Restoration'),
('Laura Johnson', 'mailto:laurajohnson@example.com', 'Silver', 'Community Education'),
('David Lee', 'mailto:davidlee@example.com', 'Basic', 'Sustainable Practices'),
('Emily Clark', 'mailto:emilyclark@example.com', 'Gold', 'Wildlife Conservation'),
('Chris Martin', 'mailto:chrismartin@example.com', 'Silver', 'Marine Conservation'),
('Sophia Brown', 'mailto:sophiabrown@example.com', 'Basic', 'Renewable Energy'),
('James Taylor', 'mailto:jamestaylor@example.com', 'Gold', 'Climate Change'),
('Olivia Davis', 'mailto:oliviadavis@example.com', 'Silver', 'Recycling'),
('Ethan Wilson', 'mailto:ethanwilson@example.com', 'Basic', 'Forest Preservation'),
('Isabella Harris', 'mailto:isabellaharris@example.com', 'Gold', 'Sustainable Living');

INSERT INTO Staff (Name, Role, ContactInfo)
VALUES 
('Alice Green', 'Project Manager', 'mailto:alicegreen@example.com'),
('Tom White', 'Field Coordinator', 'mailto:tomwhite@example.com'),
('Grace Hall', 'Wildlife Specialist', 'mailto:gracehall@example.com'),
('Henry Moore', 'Education Officer', 'mailto:henrymoore@example.com'),
('Lucas Walker', 'Forest Ranger', 'mailto:lucaswalker@example.com'),
('Mia Scott', 'Marine Biologist', 'mailto:miascott@example.com'),
('Liam Adams', 'Volunteer Coordinator', 'mailto:liamadams@example.com'),
('Emma Turner', 'Sustainability Expert', 'mailto:emmaturner@example.com'),
('Oliver Hill', 'Community Liaison', 'mailto:oliverhill@example.com'),
('Ava Baker', 'Climate Analyst', 'mailto:avabaker@example.com');

INSERT INTO Projects (ProjectName, Description, Schedule, MaxParticipants, StaffID)
VALUES 
('Wildlife Monitoring', 'Monitoring wildlife in the forest.', '2024-01-15', 10, 1),
('Tree Plantation', 'Planting trees in degraded areas.', '2024-02-10', 20, 2),
('Beach Cleanup', 'Removing trash from beaches.', '2024-03-05', 15, 6),
('River Restoration', 'Improving river ecosystems.', '2024-04-20', 12, 5),
('Renewable Energy Workshop', 'Educating on solar and wind energy.', '2024-05-25', 25, 8),
('Climate Change Seminar', 'Discussing climate change impacts.', '2024-06-15', 30, 10),
('Community Recycling Drive', 'Encouraging recycling efforts.', '2024-07-10', 50, 9),
('Wildlife Photography Expedition', 'Capturing wildlife moments.', '2024-08-01', 8, 3),
('Sustainable Farming Workshop', 'Training on eco-friendly farming.', '2024-09-10', 18, 4),
('Ocean Conservation Project', 'Protecting marine habitats.', '2024-10-05', 12, 7);

INSERT INTO Bookings (MemberID, ProjectID, BookingDate)
VALUES 
(1, 1, '2024-01-10'),
(2, 2, '2024-01-12'),
(3, 3, '2024-02-14'),
(4, 4, '2024-03-10'),
(5, 5, '2024-04-05'),
(6, 6, '2024-05-20'),
(7, 7, '2024-06-25'),
(8, 8, '2024-07-15'),
(9, 9, '2024-08-20'),
(10, 10, '2024-09-10');

-- Query to display current registrations by a member
SELECT p.ProjectName, b.BookingDate
FROM Bookings b
JOIN Projects p ON b.ProjectID = p.ProjectID
WHERE b.MemberID = 1;

-- Query to find projects led by a specific staff member
SELECT ProjectName, Description
FROM Projects
WHERE StaffID = 1;

-- Query to list the most active members
SELECT m.Name, COUNT(b.BookingID) AS ParticipationCount
FROM Bookings b
JOIN Members m ON b.MemberID = m.MemberID
GROUP BY m.MemberID
ORDER BY ParticipationCount DESC;

-- Trigger to enforce booking limits based on membership type
DELIMITER $$
CREATE TRIGGER CheckBookingLimit
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE project_count INT;
    SELECT COUNT(*) INTO project_count
    FROM Bookings
    WHERE MemberID = NEW.MemberID
    AND MONTH(BookingDate) = MONTH(CURDATE());

    IF (project_count >= (
        CASE (SELECT MembershipType FROM Members WHERE MemberID = NEW.MemberID)
            WHEN 'Basic' THEN 3
            WHEN 'Silver' THEN 4
            WHEN 'Gold' THEN 5
        END
    )) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking limit exceeded for this membership type.';
    END IF;
END$$
DELIMITER ;

-- Query to check available slots for a project
SELECT ProjectName, MaxParticipants - COUNT(b.BookingID) AS AvailableSlots
FROM Projects p
LEFT JOIN Bookings b ON p.ProjectID = b.ProjectID
WHERE p.ProjectID = 1
GROUP BY p.ProjectID;

-- Query to calculate total fees collected for extra projects
SELECT m.Name, SUM(CASE WHEN b.BookingDate > 5 THEN 10 ELSE 0 END) AS TotalFees
FROM Bookings b
JOIN Members m ON b.MemberID = m.MemberID
GROUP BY m.MemberID;

-- Query to generate monthly participation report
SELECT MONTH(b.BookingDate) AS Month, m.Name, COUNT(b.BookingID) AS ParticipationCount
FROM Bookings b
JOIN Members m ON b.MemberID = m.MemberID
GROUP BY MONTH(b.BookingDate), m.MemberID
ORDER BY Month, ParticipationCount DESC;  