USE master;  
GO  
IF DB_ID (N'QLQTKD') IS NOT NULL  
DROP DATABASE QLQTKD;  
GO  
CREATE DATABASE QLQTKD  
go
use QLQTKD
go
--
--Tạo bảng Hóa đơn nợ NPP
create table HDNoNPP
(
	MaDNo char(9) not null,
	HGD	date not null,
	STTT float not null,
	TTGD varchar(30) not null,
	primary key(MaDNo)
)
go
-- Tạo bảng NPP
create table NhaPhanPhoi
( 
	MaNPP Char(9) not null,
	TenNPP Varchar (50) not null, 
	SDT_NPP char(10) not null,
	DC_NPP Varchar(100) not null, 
	Primary key (MaNPP)
) 
go 
-- Tạo bảng Sản Phẩm
create table SanPham
(  	
	MaSP Char(9) not null,
   	TenSP Varchar(50) not null,
	DonVi Varchar(10) not null,
	GiaXuat float not null,
	LoaiHang varchar(5) not null,
   	Primary key (MaSP)
)
go
-- Tạo bảng Nhân viên
Create table NhanVien
(
MaNV char(9)  not null,
TenNV varchar(30) not null,
SDT_NV char(10) not null,
ViTri varchar(30) not null,
	primary key(MaNV)
)
go
--Tạo bảng khách hàng
Create table KhachHang 
(
MaKH char(9)  not null,
TenKH varchar(30) not null,
SDT_KH char(10) not null,
DC_KH varchar(50) not null,
	primary key(MaKH)
)
go
--Tạo bảng Kho
create table Kho
(
	MaLH char(9) not null,
	HSD date not null,
	SLHT int not null,
	GiaNhap float not null,
	primary key(MaLH)
)
go

-- Tạo bảng Nhập
create table Nhap
(
	MaHDN char(19) not null,
	MaNPP char(9) not null,
	MaNV char(9) not null,
	MaDNo char(9) not null,
	NgayNH date not null,
	TongTienNH float not null,
	primary key(MaHDN),
	foreign key (MaNPP) references NhaPhanPhoi(MaNPP),
	foreign key (MaNV) references NhanVien(MaNV),
	foreign key (MaDNo) references HDNoNPP(MaDNo)
)
go
-- Tạo bảng nhập chi tiết
create table Nhap_chitiet 
(
	MaHDN char(19) not null, 
	MaSP char(9) not null, 
	SLNH int not null, 
	KM float,
	ThanhTienNH float not null, 
	primary key (MaHDN,MaSP),
	foreign key (MaSP) references SanPham(MaSP),
	foreign key (MaHDN) references Nhap(MaHDN)
)
go
-- Tạo bảng Xuất
create table Xuat
(
	MaHDX char(9) not null,
	NgayXH date not null,
	TongTienXH float not null,
	MaKH char(9) not null,
	MaNV char(9) not null,
	primary key (MaHDX),
	foreign key (MaKH) references KhachHang (MaKH),
	foreign key (MaNV) references NhanVien (MaNV)
)
go
--Tạo bảng xuất chi tiết
create table Xuat_chitiet 
( 
	MaHDX char(9) not null, 
	MaSP char(9) not null, 
	ThanhtienXH float not null,
	SLXH int not null, 
	primary key (MaHDX,MaSP),
	foreign key (MaSP) references SanPham(MaSP),
	foreign key (MaHDX) references Xuat(MaHDX)
) 
go 
-- Tạo bảng chứa
create table Chua
(
	MaLH char(9) not null,
	MaSP char(9) not null,
	primary key (MaLH,MaSP),
	foreign key (MaLH) references Kho(MaLH),
foreign key (MaSP) references SanPham(MaSP)
)
go
