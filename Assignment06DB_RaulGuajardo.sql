--*************************************************************************--
-- Title: Assignment06DB
-- Author: Raul Guajardo
-- Desc: This file demonstrates how to use Views
-- Change Log:
-- 2021-02-21: Raul Guajardo, Created File
-- 2021-02-22: Answered questions 1 to 8
-- 2021-02-23: Answered questions 9 and 10
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_RaulGuajardo')
	 Begin 
	  Alter Database [Assignment06DB_RaulGuajardo] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_RaulGuajardo;
	 End
	Create Database Assignment06DB_RaulGuajardo;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_RaulGuajardo;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
--'NOTES------------------------------------------------------------------------------------ 
-- 1) You can use any name you like for you views, but be descriptive and consistent
-- 2) You can use your working code from assignment 5 for much of this assignment
-- 3) You must use the BASIC views for each table after they are created in Question 1
--------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


Create View vCategories
With SchemaBinding
As
  Select CategoryID, CategoryName
  From dbo.Categories;
Go

--Select * From vCategories;



Create View vProducts
With SchemaBinding
As 
  Select ProductID, ProductName, CategoryID, UnitPrice
  From dbo.Products;
Go

--Select * From vProducts;



Create View vEmployees 
With SchemaBinding
As
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
  From dbo.Employees;
Go

--Select * From vEmployees;



Create View vInventories
With SchemaBinding
As
  Select InventoryID, InventoryDate, EmployeeID, ProductID, Count
  From dbo.Inventories;
Go

--Select * From vInventories;


-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;
Go

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!


Create View vProductsByCategories
With SchemaBinding
As
   Select Top 1000000
          C.CategoryName,
          P.ProductName,
	      P.UnitPrice
   From dbo.Categories As C Inner Join dbo.Products As P
   On  C.CategoryID = P.CategoryID
   Order By 1,2 ASC;
Go

--Select * From vProductsByCategories;


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


Create View vInventoriesByProductsByDates
With SchemaBinding
As
  Select Top 1000000 
         P.ProductName,
         I.InventoryDate,
	     I.Count
  From dbo.Products As P Inner Join dbo.Inventories As I
  On P.ProductID = I.ProductID
  Order By 1,2,3 ASC;
Go

--Select * From vInventoriesByProductsByDates;


-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!


Create View vInventoriesByEmployeesByDates
With SchemaBinding
As
  SELECT DISTINCT Top 1000000
                  I.InventoryDate,
                  Substring(EmployeeFirstName + ' ' + EmployeeLastName, 1, 15) AS EmployeeName
                  From dbo.Inventories As I Inner Join dbo.Employees As E
                  On I.EmployeeID = E.EmployeeID
				  Order By 1 ASC;

Go

--Select * From vInventoriesByEmployeesByDates;

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth



-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Create View vInventoriesByProductsByCategories
With SchemaBinding
As
  Select Top 1000000
         C.CategoryName,
         P.ProductName,
	     I.InventoryDate,
	     I.Count
  From dbo.Categories As C Inner Join dbo.Products As P
  On C.CategoryID = P.CategoryID
  Inner Join dbo.Inventories as I
  On P.ProductID = I.ProductID
  Order By 1, 2, 3, 4 ASC;
Go

--Select * From vInventoriesByProductsByCategories;


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Create View vInventoriesByProductsByEmployees
With SchemaBinding
As
  Select Top 1000000
         C.CategoryName,
         P.ProductName,
	     I.InventoryDate,
	     I.Count,
	     Substring(EmployeeFirstName + ' ' + EmployeeLastName, 1, 15) As EmployeeName
  From dbo.Categories As C Inner Join dbo.Products As P
  On C.CategoryID = P.CategoryID
  Inner Join dbo.Inventories As I
  On P.ProductID = I.ProductID
  Inner Join dbo.Employees as E
  On I.EmployeeID = E.EmployeeID
  Order By 3, 1, 2, 5 ASC;
Go

--Select * From vInventoriesByProductsByEmployees;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan



-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Create View vInventoriesForChaiAndChangByEmployees
With SchemaBinding
As
  Select Top 1000000
         C.CategoryName,
         P.ProductName,
	     I.InventoryDate,
	     I.Count,
	     Substring(EmployeeFirstName + ' ' + EmployeeLastName, 1, 15) As EmployeeName
  From dbo.Categories As C Inner Join dbo.Products As P
  On C.CategoryID = P.CategoryID
  Inner Join dbo.Inventories As I
  On P.ProductID = I.ProductID
  Inner Join dbo.Employees as E
  On I.EmployeeID = E.EmployeeID
  Where P.ProductID In (Select ProductID
                        From dbo.Products
					    Where ProductName = 'Chang')
					    or P.ProductID In (Select ProductID
					                       From dbo.Products
									       Where ProductName = 'Chai')
  Order By 3,1,2 ASC;
Go

--Select * From vInventoriesForChaiAndChangByEmployees;


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Create View vEmployeesByManager
With SchemaBinding
As
Select 	Top 1000000
	    Substring(M.EmployeeFirstName + ' ' + M.EmployeeLastName, 1, 15) As Manager,
	    Substring(E.EmployeeFirstName + ' ' + E.EmployeeLastName, 1, 15) As Employee	
From dbo.Employees As E Inner Join dbo.Employees As M
On E.ManagerID = M.EmployeeID
Order By 1,2 ASC;
Go


--Select * From vEmployeesByManager;

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?


Create View vInventoriesByProductsByCategoriesByEmployees
With SchemaBinding
As 
  Select Top 1000000
         vC.CategoryID,
         vC.CategoryName,
         vP.ProductID,
		 vP.ProductName,
		 vP.UnitPrice,
		 vI.InventoryID,
		 vI.InventoryDate,
		 vI.Count,
		 vI.EmployeeID,
		 Substring(vE.EmployeeFirstName + ' ' + vE.EmployeeLastName, 1, 15) As Employee,
		 Substring(vM.EmployeeFirstName + ' ' + vM.EmployeeLastName, 1, 15) As Manager
  From dbo.vCategories As vC Inner Join dbo.vProducts As vP
  On vC.CategoryID = vP.CategoryID
  Inner Join dbo.vInventories As vI
  On vP.ProductID = vI.ProductID
  Inner Join dbo.vEmployees as vE
  On vI.EmployeeID = vE.EmployeeID
  Inner Join dbo.vEmployees as vM
  On vM.EmployeeID = vE.ManagerID
  Order By 1, 2, 3 ASC;
Go


--Select * From vInventoriesByProductsByCategoriesByEmployees;


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)

Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

Use Master;
Go

/***************************************************************************************/