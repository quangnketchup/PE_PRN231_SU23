USE master
GO

CREATE DATABASE PetShop2023DB
GO

USE PetShop2023DB
GO

CREATE TABLE PetShopMember(
  MemberID nvarchar(20) primary key,
  MemberPassword nvarchar(80) not null,
  FullName nvarchar(80) not null,
  EmailAddress nvarchar(100) unique, 
  MemberRole int
)
GO

INSERT INTO PetShopMember VALUES(N'PS0001',N'@1', N'Administrator', 'admin@PetStore.com.au', 1);
INSERT INTO PetShopMember VALUES(N'PS0002',N'@2', N'Staff', 'staff@PetStore.com.au', 2);
INSERT INTO PetShopMember VALUES(N'PS0003',N'@3', N'Member 1', 'member1@PetStore.com.au', 3);
INSERT INTO PetShopMember VALUES(N'PS0004',N'@3', N'Member 2', 'member2@PetStore.com.au', 3);
GO


CREATE TABLE PetGroup(
  PetGroupId nvarchar(20) primary key,
  PetGroupName nvarchar(80) not null,
  GroupDescription nvarchar(150), 
  OriginalSource nvarchar(60)
)
GO
INSERT INTO PetGroup VALUES(N'PG0001',N'Dogs',N'They are incredibly loyal pets and great companions.', N'Viet Nam')
INSERT INTO PetGroup VALUES(N'PG0002',N'Cats',N'They are independent yet affectionate pets and easy to take care of.', N'Thailand')
INSERT INTO PetGroup VALUES(N'PG0003',N'Birds',N'They are a great choice for those who enjoy their chirping and singing.', N'US')
INSERT INTO PetGroup VALUES(N'PG0004',N'Fish',N'They are low-maintenance pets that add a calming element to any home.', N'South Korea')
INSERT INTO PetGroup VALUES(N'PG0005',N'Rabbits',N'They are great for those who want a furry friend that is affectionate and playful.', N'Austraulia')
INSERT INTO PetGroup VALUES(N'PG0006',N'Guinea Pigs',N'They are social animals that are great for families and children due to their gentle temperament.', N'UK')
INSERT INTO PetGroup VALUES(N'PG0007',N'Hamsters',N'They are easy to care for and great for those looking for a small, low-maintenance pet.', N'Mexico')
INSERT INTO PetGroup VALUES(N'PG0008',N'Reptiles',N'They are fascinating pets that require more specialized care, but can be rewarding for experienced pet owners.', N'Nauy')
INSERT INTO PetGroup VALUES(N'PG0009',N'Ferrets',N'They are playful and affectionate pets that require a bit of training but can be great for those who want a unique furball.', N'Singapore')

GO

CREATE TABLE Pet (
 PetId int primary key,
 PetName nvarchar(200) not null,
 ImportDate datetime,
 PetDescription nvarchar(220),
 Quantity int,
 PetPrice float,
 PetGroupId nvarchar(20) references PetGroup(PetGroupId) on delete cascade on update cascade
)
GO


INSERT INTO Pet VALUES(1,N'Phu Quoc Ridgeback',CAST(N'2022-03-25' AS DateTime),N'This breed is indigenous to Phu Quoc Island, Vietnam and is known for its short, smooth coat and ridges along the spine. They are athletic and excel at hunting and guarding.',12, 1900000,'PG0001')
INSERT INTO Pet VALUES(2,N'Vietnamese Hound',CAST(N'2022-09-15' AS DateTime), N'Also known as the Bac Ha dog, this breed originates from northern Vietnam and was originally bred for hunting and herding.',30,2000000,'PG0001')
INSERT INTO Pet VALUES(3,N'Vietnamese Greyhound',CAST(N'2022-08-05' AS DateTime),N'This breed is a result of cross-breeding of local village dogs with Greyhounds brought over by French colonizers. They are fast, agile, and used for hunting and racing.',15,1800000, 'PG0001')
INSERT INTO Pet VALUES(4,N'Vietnamese Bulldog',CAST(N'2022-09-16' AS DateTime),N'Also known as the Hanoi Bulldog, they are a larger breed with a strong, muscular build. They are commonly used as guard dogs and for hunting.',20,1700000, 'PG0001')

INSERT INTO Pet VALUES(5,N'Siamese Cats',CAST(N'2022-03-25' AS DateTime),N'They have short hair with a pointed pattern, meaning their coat color is lighter on their torso and darker on their extremities.',32, 1200000,'PG0002')
INSERT INTO Pet VALUES(6,N'Korat Cats',CAST(N'2022-09-15' AS DateTime), N'Korat cats are a breed of cat that originated in Thailand and are known for their blue-grey coats. Their coats are glossy and they have distinctive green-yellow eyes.',14,1400000,'PG0002')
INSERT INTO Pet VALUES(7,N'Burmese Cats',CAST(N'2022-08-05' AS DateTime),N'Burmese cats are a breed of cat that originated in Thailand and are known for their short, shiny coats. They come in a range of colors including brown, blue, chocolate, and lilac.',17,1100000, 'PG0002')
INSERT INTO Pet VALUES(8,N'Khao Manee Cats',CAST(N'2022-09-16' AS DateTime),N'Khao Manee cats are a rare breed of cat originating in Thailand. They are known for their pure white coats and odd (one blue and one yellow) or blue eyes. They are a very rare and prized breed of cat.',11,1000000, 'PG0002')

INSERT INTO Pet VALUES(9,N'The Mexican Hamster',CAST(N'2022-08-05' AS DateTime),N'It is a small and cute rodent that is often kept as a pet. The Mexican Hamster has a furry coat that is light brown or gray in color.',17,1300000, 'PG0007')
INSERT INTO Pet VALUES(10,N'The Black-bellied Hamster',CAST(N'2022-09-16' AS DateTime),N'The Black-bellied Hamster is an omnivore and feeds on seeds, insects, and vegetation.',11,1200000, 'PG0007')
GO