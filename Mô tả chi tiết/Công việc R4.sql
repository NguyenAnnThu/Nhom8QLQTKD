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
go
create table HDNoNPP
(
	MaDNo nchar(9) not null,
	HGD	date not null,
	STTT float not null,
	TTGD nvarchar(30) not null,
	primary key(MaDNo)
)
go
-- Tạo bảng NPP
go
create table NhaPhanPhoi
( 
	MaNPP nChar(9) not null,
	TenNPP nVarchar (50) not null, 
	SDT_NPP nchar(10) not null,
	DC_NPP nVarchar(100) not null, 
	Primary key (MaNPP)
) 
go 
-- Tạo bảng Sản Phẩm
go
create table SanPham
(  	
	MaSP nChar(9) not null,
   	TenSP nVarchar(50) not null,
	DonVi nVarchar(10) not null,
	LoaiHang nvarchar(5) not null,
   	Primary key (MaSP)
)
go

-- Tạo bảng Nhân viên
Create table NhanVien
(
	MaNV nchar(9)  not null,
	TenNV nvarchar(30) not null,
	SDT_NV nchar(10) not null,
	ViTri nvarchar(30) not null,
	primary key(MaNV)
)
go
--Tạo bảng khách hàng
Create table KhachHang 
(
	MaKH nchar(9)  not null,
	TenKH nvarchar(30) not null,
	SDT_KH nchar(10) not null,
	DC_KH nvarchar(50) not null,
	primary key(MaKH)
)
go
--Tạo bảng Kho
create table Kho
(
	MaLH nchar(9) not null,
	HSD nvarchar(40) not null,
	SLHT int not null,
	primary key(MaLH)
)
go
-- Tạo bảng Nhập
create table Nhap
(
	MaHDN nchar(9) not null,
	MaNPP nchar(9) not null,
	MaNV nchar(9) not null,
	MaDNo nchar(9) not null,
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
	MaHDN nchar(9) not null, 
	MaSP nchar(9) not null, 
	SLNH int not null, 
	ThanhTienNH float not null,
	GiaNhap float not null,
	primary key (MaHDN,MaSP),
	foreign key (MaSP) references SanPham(MaSP),
	foreign key (MaHDN) references Nhap(MaHDN)
)
go
-- Tạo bảng Xuất
create table Xuat
(
	MaHDX nchar(9) not null,
	NgayXH date not null,
	TongTienXH float not null,
	MaKH nchar(9) not null,
	MaNV nchar(9) not null,
	primary key (MaHDX),
	foreign key (MaKH) references KhachHang (MaKH),
	foreign key (MaNV) references NhanVien (MaNV)
)
go
--Tạo bảng xuất chi tiết
create table Xuat_chitiet 
( 
	MaHDX nchar(9) not null, 
	MaSP nchar(9) not null, 
	ThanhtienXH float not null,
	SLXH int not null, KM float null,
	GiaXuat float not null,
	primary key (MaHDX,MaSP),
	foreign key (MaSP) references SanPham(MaSP),
	foreign key (MaHDX) references Xuat(MaHDX)
) 
go 
-- Tạo bảng chứa
create table Chua
(
	MaLH nchar(9) not null,
	MaSP nchar(9) not null,
	primary key (MaLH,MaSP),
	foreign key (MaLH) references Kho(MaLH),
foreign key (MaSP) references SanPham(MaSP)
)
go
-- Chèn dữ liệu vào bảng--
--2 Nhà phân phối----
go
create or alter proc sp_NhaPhanPhoi 
as
begin
    declare @i int =1;
	declare @ma nvarchar(10),@ten nvarchar(30),@sdt nvarchar(10),@dc nvarchar(100)
    --ten:nhaphanphoi+i
	--sdt: đầu số
	--DC_NPP+i
	select @i = isnull(cast(right(max(MaNPP), 6) as int), 0) + 1 from NhaPhanPhoi
	declare @DauSo table (DauSo char(3));
    insert into @DauSo values 
        ('086'), ('096'), ('097'), ('098'), 
        ('039'), ('038'), ('037'), ('036'), 
        ('035'), ('034'), ('033'), ('032'), 
        ('091'), ('094'), ('088'), ('083'), 
        ('084'), ('085'), ('081'), ('082'), 
        ('070'), ('079'), ('077'), ('076'), 
        ('078'), ('089'), ('090'), ('093');

    while @i<=1000
    begin
		set @ma= 'NPP_'+ right('00000' + CAST(@i AS VARCHAR(5)), 5)
		set @ten='NhaPhanPhoi'+cast(@i as varchar(7))
		select @sdt = (select top 1 DauSo from @DauSo order by newid()) 
            + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7));
        
        while exists (select 1 from NhanVien where SDT_NV = @sdt)
        begin
            select @sdt = (select top 1 DauSo from @DauSo order by newid()) 
                + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7));
        end
		set @dc= 'DC_NPP' +cast(@i as varchar(7))
        insert into NhaPhanPhoi (MaNPP, TenNPP, SDT_NPP, DC_NPP)
        values(@ma,@ten,@sdt,@dc);
        set @i = @i + 1;
	end
end
go
exec sp_NhaPhanPhoi
select * from NhaPhanPhoi
delete NhaPhanPhoi
drop proc sp_NhaPhanPhoi
----- 3 Khách hàng ---
go
create or alter proc sp_KhachHang
as
begin
    declare @i int =1;
    declare @MaKH nchar(9)
    declare @TenKH nvarchar(30)
    declare @SDT_KH char(10)
    declare @DC_KH nvarchar(50)

    declare @DauSo table (DauSo char(3));
    insert into @DauSo values 
        ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), ('036'), ('035'), ('034'), ('033'), ('032'), 
        ('091'), ('094'), ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), 
        ('070'), ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

    select @i = isnull(cast(right(max(MaKH), 6) as int), 0) + 1 from KhachHang;

    while @i<=1000
    begin
        set @MaKH = 'KH_' + right('000000' + cast(@i as varchar(6)), 6);

        set @TenKH = N'Khách hàng ' + cast(@i as varchar(10));

        select @SDT_KH = (select top 1 DauSo from @DauSo order by newid()) 
            + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7));

        while exists (select 1 from KhachHang where SDT_KH = @SDT_KH)
        begin
            select @SDT_KH = (select top 1 DauSo from @DauSo order by newid()) 
                + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7));
        end

        set @DC_KH = 'DC_KH' + cast(@i as varchar(10)) 
        insert into KhachHang (MaKH, TenKH, SDT_KH, DC_KH)
        values (@MaKH, @TenKH, @SDT_KH, @DC_KH);

        set @i = @i + 1;
    end
end
go
exec sp_KhachHang 
select * from KhachHang;
delete KhachHang

---- 4: sản phẩm---
go
create or alter proc sp_SanPham 
as
begin
	declare @i int =1;
	declare @ma nvarchar(9),@ten nvarchar(50),@dv nvarchar(20),
			@LH nvarchar (50),@KH nvarchar(30)
	select @i = isnull(cast(right(max(MaSP), 6) as int), 0) + 1 from SanPham
	declare @H table (H nvarchar(50));
    insert into @H values 
				(N'AV'),(N'Sữa'),(N'ĐH'),(N'GV'),(N'LT');
	declare @d table (D nvarchar (30));
	insert into @D values
				(N'Hộp'),(N'Thùng');
	WHILE @i<=1000
	BEGIN
		set @ma= 'SP_'+ right('000000' + CAST(@i AS VARCHAR(6)), 6)
		select @LH= (select top 1 h from @H order by newid()) 
		set @ten='SP_'+@LH+ cast(@i as nvarchar (7))
		SElect @dv =(select top 1 D from @D order by newid()) 
		-- Chèn dữ liệu vào bảng tạm
		INSERT INTO SanPham(MaSP, TenSP, DonVi, LoaiHang)
		VALUES (@ma, @ten, @dv, @LH);
		SET @i = @i + 1;
	end;
end;
go
exec sp_SanPham 
select * from SanPham
delete SanPham

-- 5 Nhân viên ---
go
create or alter proc sp_NhanVien 
as
begin
    declare @i int =1;
    declare @sdt char(10)
    declare @vitri_nv nvarchar(30)
    declare @tennv nvarchar(30)
    declare @manv char(9)
    declare @vitriQuanLyCount int = 0

    select @i = isnull(cast(right(max(manv), 6) as int), 0) + 1 from NhanVien

    declare @ViTriTable table (ViTri nvarchar(30))  
    insert into @ViTriTable values 
        (N'Quản lý'),
        (N'Nhân viên kho'),
        (N'Nhân viên thu ngân'),
        (N'Nhân viên bán hàng')

    declare @DauSo table (DauSo char(3))
    insert into @DauSo values 
        ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), ('036'), ('035'), ('034'), ('033'), ('032'), 
        ('091'), ('094'), ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), 
        ('070'), ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

    while @i<=1000
    begin
        set @manv = 'NV_' + right('000000' + cast(@i as nvarchar(6)), 6)

        set @tennv = 'Nhân viên ' + cast(@i as nvarchar(10))

        select @sdt = (select top 1 DauSo from @DauSo order by newid()) 
            + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7))
        
        while exists (select 1 from NhanVien where SDT_NV = @sdt)
        begin
            select @sdt = (select top 1 DauSo from @DauSo order by newid()) 
                + cast((1000000 + abs(checksum(newid())) % 9000000) as char(7))
        end

        if @vitriQuanLyCount < 2
        begin
            select @vitri_nv = (select top 1 ViTri from @ViTriTable order by newid()) 
            if @vitri_nv = N'Quản lý'
            begin
                set @vitriQuanLyCount = @vitriQuanLyCount + 1
            end
        end
        else
        begin
            select @vitri_nv = (select top 1 ViTri from @ViTriTable where ViTri != N'Quản lý' order by newid())
        end

        insert into NhanVien (MaNV, TenNV, SDT_NV, ViTri)
        values (@manv, @tennv, @sdt, @vitri_nv)

        set @i = @i + 1
    end
end
go
exec sp_NhanVien
select * from NhanVien
delete NhanVien

--- HDN+N+NCT
go
create or alter procedure sp_Nhap
as
begin
    declare @i int = 1;
    declare @MaHDN char(9); -- mã hóa đơn nhập
    declare @NgayNH date; -- ngày nhập
    declare @TongTienNH float = 0; -- tổng tiền nhập
    declare @MaNPP char(9); -- mã nhà phân phối
    declare @MaNV char(9); -- mã nhân viên
    declare @MaDNo char(9); -- mã đơn nợ
    declare @MaSP char(9); -- mã sản phẩm
    declare @ThanhTienNH float; -- thành tiền nhập
    declare @SLNH int; -- số lượng nhập
    declare @GiaNhap float; -- giá nhập
    declare @hgd date; -- hạn giao dịch
    declare @ttgd nvarchar(30); -- tình trạng giao dịch
    declare @sttt float = 0; -- số tiền thanh toán trước

    while @i <= 1000
    begin
        set @MaHDN = 'HDN_' + right('00000' + cast(@i as varchar(5)),5);
        set @MaDNo = right('000000000' + cast(@i as varchar(9)), 9);

        -- Lấy mã nhà phân phối và nhân viên ngẫu nhiên
        select top 1 @MaNPP = MaNPP from NhaPhanPhoi order by newid();
        select top 1 @MaNV = MaNV from NhanVien where ViTri like N'%kho' order by newid();

        -- Tạo ngày nhập và hạn giao dịch
        set @NgayNH = dateadd(day, abs(checksum(newid()) % datediff(day, '2023-01-01', getdate())), '2023-01-01');
        set @hgd = dateadd(month, 6, @NgayNH);

        -- Xác định tình trạng giao dịch
        if @hgd < getdate()
            set @ttgd = N'Hoàn thành';
        else
            set @ttgd = case when abs(checksum(newid())) % 2 = 0 then N'Hoàn thành' else N'Chưa hoàn thành' end;

        set @sttt = 0

        -- Thêm dữ liệu vào bảng HDNoNPP
        insert into HDNoNPP (MaDNo, HGD, STTT, TTGD)
        values (@MaDNo, @hgd, @sttt, @ttgd);

        -- Thêm dữ liệu vào bảng Nhap
        insert into Nhap (MaHDN, MaNPP, MaNV, MaDNo, NgayNH, TongTienNH)
        values (@MaHDN, @MaNPP, @MaNV, @MaDNo, @NgayNH, @TongTienNH);

        -- Đặt lại tổng tiền nhập
        set @TongTienNH = 0;

        -- Số sản phẩm trong mỗi hóa đơn nhập
        declare @soSanPham int = abs(checksum(newid()) % 5) + 1;
        while @soSanPham > 0
        begin
            -- Kiểm tra số lượng bản ghi trong bảng Nhap_ChiTiet
            declare @y int;
            select @y = count(*) from Nhap_ChiTiet;

            if @y < 1000
            begin
                -- Random mã sản phẩm nếu đã tồn tại trong Nhap_ChiTiet thì random lại
                declare @x int = 1;
                while @x = 1
                begin
                    select top 1 @MaSP = MaSP from SanPham order by newid();
                    if exists (select 1 from Nhap_ChiTiet where MaSP = @MaSP)
                        set @x = 1; -- Nếu mã sản phẩm tồn tại thì random lại
                    else
                        set @x = 0; -- Nếu mã không tồn tại, thoát khỏi vòng lặp
                end;
            end
            else
            begin
                -- Chọn ngẫu nhiên mã sản phẩm nếu số bản ghi > 1000
                select top 1 @MaSP = MaSP from SanPham order by newid();
            end;

            -- Lấy giá nhập từ bảng Nhap_ChiTiet hoặc tự tạo ngẫu nhiên nếu không có giá
            if not exists (select GiaNhap from Nhap_ChiTiet where MaSP = @MaSP)
                set @GiaNhap = cast((rand() * (500000 - 10000) + 10000) as numeric);
            else
                select @GiaNhap = GiaNhap from Nhap_ChiTiet where MaSP = @MaSP;

            -- Lấy số lượng nhập ngẫu nhiên
            set @SLNH = cast((rand() * (500 - 200) + 200) as numeric);

            -- Tính thành tiền nhập
            set @ThanhTienNH = @SLNH * @GiaNhap;

            -- Cộng dồn tổng tiền nhập
            set @TongTienNH = @TongTienNH + @ThanhTienNH;

            -- Thêm chi tiết nhập vào bảng Nhap_ChiTiet
            insert into Nhap_ChiTiet (MaHDN, MaSP, SLNH, ThanhTienNH, GiaNhap)
            values (@MaHDN, @MaSP, @SLNH, @ThanhTienNH, @GiaNhap);

            -- Giảm số lượng sản phẩm cần thêm
            set @soSanPham = @soSanPham - 1;
        end;

        -- Cập nhật tổng tiền nhập trong bảng Nhap
        update Nhap
        set TongTienNH = @TongTienNH
        where MaHDN = @MaHDN;

        set @sttt = round(0.3 * @TongTienNH, 2);

        -- Cập nhật số tiền thanh toán trước trong bảng HDNoNPP
        update HDNoNPP
        set STTT = @sttt
        where MaDNo = @MaDNo;

        -- Tăng biến đếm và tiếp tục
        set @i = @i + 1;
    end
end;
go

exec sp_Nhap
--
select * from Nhap
select * from Nhap_chitiet
select * from HDNoNPP

--
delete Nhap
delete HDNoNPP
delete Nhap_chitiet
-- Xuất và Xuất_ChiTiet
go
create or alter procedure sp_Xuat 
as
begin
    declare @i int = 1;
    declare @MaHDX char(9);
    declare @NgayXH date;
    declare @TongTienXH float;
    declare @MaKH char(9);
    declare @MaNV char(9);
    declare @MaSP char(9);
    declare @ThanhTienXH float;
    declare @SLXH int;
    declare @KM float;
    declare @MaxDate date = getdate();  -- Ngày hiện tại
    declare @GiaXuat float;

    while @i <= 1000
    begin
        -- Tạo mã hóa đơn xuất
        set @MaHDX = 'HDX_' + right('000000' + cast(@i as varchar(5)), 5);

        -- Lấy mã khách hàng và mã nhân viên ngẫu nhiên
        select top 1 @MaKH = MaKH from KhachHang order by newid();
        select top 1 @MaNV = MaNV from NhanVien where ViTri like N'%[bán hàng,thu ngân]' order by newid();

        -- Tạo ngày xuất ngẫu nhiên
        set @NgayXH = dateadd(day, abs(checksum(newid()) % datediff(day, '2023-01-01', @MaxDate)), '2023-01-01');

        -- Khởi tạo tổng tiền xuất = 0
        set @TongTienXH = 0;

        -- Thêm dữ liệu vào bảng Xuất
        insert into Xuat (MaHDX, NgayXH, TongTienXH, MaKH, MaNV)
        values (@MaHDX, @NgayXH, @TongTienXH, @MaKH, @MaNV);

        -- Sinh dữ liệu chi tiết cho hóa đơn xuất
        declare @soSanPham int = abs(checksum(newid()) % 5) + 1;  -- Số sản phẩm trong mỗi hóa đơn xuất
        while @soSanPham > 0
        begin
            -- Lấy mã sản phẩm ngẫu nhiên
            declare @y int;
            select @y = count(*) from Xuat_chitiet;

            if @y < 1000
            begin
                -- Random mã sản phẩm nếu đã tồn tại
                declare @x int = 1;
                while @x = 1
                begin
                    select top 1 @MaSP = MaSP from SanPham order by newid();
                    if exists (select 1 from Xuat_chitiet where MaSP = @MaSP)
                        set @x = 1;
                    else
                        set @x = 0;
                        set @SLXH = CAST((RAND() * (200 - 1) + 1) AS int);
                end;
            end
            else
            begin
                declare @g int = 1;
                while @g = 1
                begin
                    select top 1 @MaSP = MaSP from SanPham order by newid();

                    -- Kiểm tra tồn kho
                    declare @xuat int, @nhap int;
                    select @xuat = isnull(sum(SLXH), 0) from Xuat_chitiet where MaSP = @MaSP;
                    select @nhap = isnull(sum(SLNH), 0) from Nhap_chitiet where MaSP = @MaSP;

                    if @nhap > @xuat
                    begin
                        set @SLXH = CAST((RAND() * (@nhap - @xuat - 1) + 1) AS int);
                        set @g = 0;
                    end
                    else
                    begin
                        set @g = 1;
                    end;
                end;
            end;

            -- Tính giá xuất
            declare @gn numeric;
            select @gn = GiaNhap from Nhap_chitiet where MaSP = @MaSP;
            set @GiaXuat = round(@gn / 0.7, 2);

            -- Tính khuyến mãi và thành tiền
            set @KM = round(abs(checksum(newid()) % 10) / 100.0, 2);
            set @ThanhTienXH = @SLXH * @GiaXuat - (@KM * @SLXH * @GiaXuat);
            set @TongTienXH = @TongTienXH + @ThanhTienXH;

            -- Thêm vào bảng Xuất_Chi tiết
            insert into Xuat_chitiet(MaHDX, MaSP, ThanhTienXH, GiaXuat, SLXH, KM)
            values (@MaHDX, @MaSP, @ThanhTienXH, @GiaXuat, @SLXH, @KM);

            set @soSanPham = @soSanPham - 1;
        end;

        -- Cập nhật tổng tiền xuất cho hóa đơn
        update Xuat
        set TongTienXH = @TongTienXH
        where MaHDX = @MaHDX;

        set @i = @i + 1;
    end;
end;
go

exec sp_Xuat;
select * from Xuat;
select * from Xuat_chitiet;
delete Xuat;
delete Xuat_chitiet;

drop proc sp_Xuat

--- 6: Kho + Chứa ---
go
create or alter procedure sp_LoHang
as
begin
    declare @i int = 1;
    declare @MaLH char(9);
    declare @MaSP char(9);
    declare @HSD nvarchar(40);
    declare @SLHT int = 0;
    declare @GiaNhap float;
    declare @GiaXuat float;
    declare @lh nvarchar(40);
    declare @nn date;
    declare @a int;
    declare @b int;

    while @i <= 1000
    begin
        -- Tạo mã lô hàng
        set @MaLH = 'LH_' + right('000000' + cast(@i as varchar(6)), 6);

        -- Lấy mã sản phẩm ngẫu nhiên từ bảng SanPham, nếu mã đã tồn tại trong bảng Chua thì random lại
        declare @x int = 1;
        while @x = 1
        begin
            select top 1 @MaSP = MaSP from SanPham order by newid();
            -- Kiểm tra xem mã sản phẩm có tồn tại trong bảng Chua hay không
            if exists (select 1 from Chua where MaSP = @MaSP)
                set @x = 1;
            else
                set @x = 0;
        end;

        -- Lấy số lượng hiện tại bằng hiệu giữa số lượng nhập và xuất
        select @a = isnull(sum(SLNH), 0) from Nhap_ChiTiet where MaSP = @MaSP;
        select @b = isnull(sum(SLXH), 0) from Xuat_ChiTiet where MaSP = @MaSP;
        set @SLHT = @a - @b;

        -- Tạo hạn sử dụng ngẫu nhiên dựa trên loại hàng
        select @lh = LoaiHang from SanPham where MaSP = @MaSP;
        set @HSD = case when @lh like N'AV' then N'6 tháng'
                        when @lh like N'GV' then N'6 tháng'
                        when @lh like N'LT' then N'2 năm'
                        when @lh like N'Sữa' then N'6 tháng'
                        else N'1 năm'
                    end;

        -- Thêm dữ liệu vào bảng Kho
        insert into Kho (MaLH, HSD, SLHT)
        values (@MaLH, @HSD, @SLHT);

        -- Thêm dữ liệu vào bảng Chua
        insert into Chua (MaLH, MaSP)
        values (@MaLH, @MaSP);

        -- Tăng biến đếm
        set @i = @i + 1;
    end
end
go

exec sp_LoHang
select * from Chua
select * from Kho
delete Chua
delete Kho

drop proc sp_LoHang

-----------------------------\MODULE\-----------------------------------------------------------
--Module 1 : TaoMa---
go
create or alter function TaoMa(@TenBang nvarchar(50))
returns nvarchar(30)
as
begin
	declare @MaCu nvarchar(20), @ma nvarchar(20),@MaMoi nvarchar(30)
	if @TenBang like N'SanPham'
	begin
		set @MaCu=(select max(MaSP) from SanPham)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 4, 6) AS INT);

        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'SP_' + RIGHT('000000' + CAST(@ma AS NVARCHAR(6)), 6);
	end
	else if @TenBang like N'KhachHang'
	begin
		set @MaCu=(select max(MaKH) from KhachHang)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 4, 6) AS INT);

        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'KH_' + RIGHT('000000' + CAST(@ma AS NVARCHAR(6)), 6);
	end
	else if @TenBang like N'HDNoNPP'
		begin
		set @MaCu=(select max(MaDNo) from HDNoNPP)
        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = RIGHT('000000000' + CAST(@ma AS NVARCHAR(9)), 9);
	end
	else if @TenBang like N'Kho'
	begin
		set @MaCu=(select max(MaLH) from Kho)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 4, 6) AS INT);

        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'LH_' + RIGHT('000000' + CAST(@ma AS NVARCHAR(6)), 6);
	end
		else if @TenBang like N'NhanVien'
	begin
			set @MaCu=(select max(MaNV) from NhanVien)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 4, 6) AS INT);

        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'NV_' + RIGHT('000000' + CAST(@ma AS NVARCHAR(6)), 6);
	end
	else if @TenBang like N'Nhap' or @TenBang like N'Nhap_chitiet'
	begin
		set @MaCu=(select max(MaHDN) from Nhap)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 5, 6) AS INT);
        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;
        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'HDN_' + RIGHT('00000' + CAST(@ma AS NVARCHAR(5)),5);
	end
	else if @TenBang like N'Xuat' or @TenBang like N'Xuat_chitiet'
	begin
			set @MaCu=(select max(MaHDX) from Xuat)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 5, 6) AS INT);

        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;

        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'HDX_' + RIGHT('00000' + CAST(@ma AS NVARCHAR(5)),5);
	end
	else if @TenBang like N'NhaPhanPhoi'
	begin
		set @MaCu=(select max(MaNPP) from NhaPhanPhoi)
		SET @MaCu = CAST(SUBSTRING(@MaCu, 5, 6) AS INT);
        -- Tăng phần số lên 1
        SET @ma = @MaCu + 1;
        -- Định dạng mã mới với tiền tố 'SP_' và phần số có độ dài 6 chữ số
        SET @MaMoi = 'NPP_' + RIGHT('00000' + CAST(@ma AS NVARCHAR(5)),5);
	end
	return @MaMoi
end

select dbo.TaoMa('Xuat_chitiet')
--Module2 CapNhatTTNV---

go
CREATE OR ALTER TRIGGER Trg_CapnhatTTNV
ON NhanVien
AFTER UPDATE
AS
BEGIN
    -- Kiểm tra sự tồn tại của bản ghi được cập nhật
    IF EXISTS (SELECT 1 FROM inserted)
    BEGIN
        -- Kiểm tra và cập nhật số điện thoại
        IF EXISTS (SELECT 1 FROM inserted i JOIN NhanVien n ON i.MaNV = n.MaNV 
							 WHERE i.SDT_NV <> n.SDT_NV)
        BEGIN
            DECLARE @sdt CHAR(10);
            DECLARE @manv CHAR(9);

            SELECT @sdt = i.SDT_NV, @manv = i.MaNV 
            FROM inserted i;
            -- Kiểm tra nếu số điện thoại đã tồn tại trong hệ thống
            IF EXISTS (SELECT 1 FROM NhanVien WHERE SDT_NV = @sdt)
            BEGIN
                PRINT N'Số điện thoại đã tồn tại trong hệ thống';
                ROLLBACK;
                RETURN;
            END
            DECLARE @dauso TABLE (dauso CHAR(3));
            INSERT INTO @dauso VALUES ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), 
                                       ('036'), ('035'), ('034'), ('033'), ('032'), ('091'), ('094'), 
                                       ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), ('070'), 
                                       ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

            -- Kiểm tra đầu số hợp lệ
            IF EXISTS (SELECT 1 FROM @dauso WHERE dauso = LEFT(@sdt, 3))
            BEGIN
                PRINT N'Cập nhật số điện thoại mới thành công';
            END
            ELSE
            BEGIN
                PRINT N'Số điện thoại không hợp lệ';
                ROLLBACK; 
                RETURN;
            END
        END
        -- Kiểm tra và cập nhật vị trí công việc
        IF EXISTS (SELECT 1 FROM inserted i JOIN NhanVien n ON i.MaNV = n.MaNV 
							WHERE i.ViTri <> n.ViTri)
        BEGIN
            DECLARE @vitri NVARCHAR(50);
            SELECT @vitri = i.ViTri 
									FROM inserted i;
            DECLARE @bangvitri TABLE (vitri NVARCHAR(50));
            INSERT INTO @bangvitri VALUES (N'Quản lý'), (N'Nhân viên thu ngân'), 
                                          (N'Nhân viên bán hàng'), (N'Nhân viên kho');
            IF EXISTS (SELECT 1 FROM @bangvitri WHERE vitri = @vitri)
            BEGIN
                PRINT N'Cập nhật vị trí mới thành công';
            END
            ELSE
            BEGIN
                PRINT N'Vị trí này không có trong hệ thống';
                ROLLBACK;  -- Hủy bỏ giao dịch nếu có sự cố
                RETURN;
            END
        END
    END
END
GO
select * from NhanVien
UPDATE NhanVien
SET SDT_NV = '0817347562', ViTri = N'Quản lý'
WHERE MaNV = 'NV_000001';

---Module 3 Cập nhật giá bán , giá nhập
go
CREATE or alter TRIGGER Trg_CapNhatGia
ON Nhap_ChiTiet
AFTER INSERT, UPDATE
AS
BEGIN
    DECLARE @MaSP NCHAR(9), @GiaNhapMoi FLOAT, @SLNH INT;
    SELECT @MaSP = MaSP, @GiaNhapMoi = GiaNhap, @SLNH = SLNH
    FROM inserted;
    -- Kiểm tra MaSP có tồn tại trong SanPham
    IF EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @MaSP)
    BEGIN
        -- Nếu sản phẩm đã tồn tại
        -- Cập nhật SLHT trong Kho
        UPDATE Kho
        SET SLHT = SLHT + @SLNH
        WHERE MaLH IN (SELECT MaLH FROM Chua WHERE MaSP = @MaSP);

        -- Lấy GiaNhapCu từ Nhap_ChiTiet
        DECLARE @GiaNhapCu FLOAT;
        SELECT TOP 1 @GiaNhapCu = GiaNhap
        FROM Nhap_ChiTiet
        WHERE MaSP = @MaSP
        ORDER BY MaHDN DESC; 

        -- So sánh GiaNhapMoi và GiaNhapCu
        IF @GiaNhapMoi <> @GiaNhapCu
        BEGIN
            -- Cập nhật GiaNhapMoi trong Nhap_ChiTiet
            UPDATE Nhap_ChiTiet
            SET GiaNhap = @GiaNhapMoi
            WHERE MaSP = @MaSP and GiaNhap = @GiaNhapCu;

            -- Cập nhật GiaXuatMoi trong Xuat_ChiTiet
            UPDATE Xuat_ChiTiet
            SET GiaXuat = 1.3 * @GiaNhapMoi
            WHERE MaSP = @MaSP;
        END
    END
    ELSE
    BEGIN
        -- Nếu sản phẩm chưa tồn tại
        -- Thêm sản phẩm mới vào SanPham, đảm bảo cung cấp giá trị cho MaSP
        INSERT INTO SanPham (MaSP, TenSP, DonVi, LoaiHang)
        VALUES (@MaSP, 'Ten SP Moi', 'Don Vi', 'Loai Hang'); 

        -- Cập nhật SLHT trong Kho (giả định đã có MaLH)
        UPDATE Kho
        SET SLHT = @SLNH
        WHERE MaLH IN (SELECT MaLH FROM Chua WHERE MaSP = @MaSP);
		declare @maxNgayNH date,@maxNgayXH date
		SELECT @MaxNgayNH = MAX(NgayNH)
		FROM Nhap;
		SELECT @MaxNgayXH = MAX(NgayXH)
		FROM Xuat;
        -- Cập nhật GiaNhapMoi và GiaXuatMoi vào Nhap_ChiTiet và Xuat_ChiTiet
        UPDATE Nhap_ChiTiet
        SET GiaNhap = @GiaNhapMoi
        WHERE MaSP = @MaSP 
		AND MaHDN IN (SELECT MaHDN FROM Nhap WHERE NgayNH = @MaxNgayNH);

        UPDATE Xuat_ChiTiet
        SET GiaXuat = 1.3 * @GiaNhapMoi
        WHERE MaSP = @MaSP
		AND MaHDX IN (SELECT MaHDX FROM Xuat WHERE NgayXH = @MaxNgayXH);
    END
END
DROP TRIGGER Trg_CapNhatGia
GO

-- Test---
INSERT INTO Nhap_ChiTiet (MaHDN, MaSP, SLNH, ThanhTienNH, GiaNhap)
VALUES ('HDN_01001', 'SP_000128', 50, 60000, 10000); 
INSERT INTO Nhap_ChiTiet (MaHDN, MaSP, SLNH, ThanhTienNH, GiaNhap)
VALUES ('', 'SP_000004', 50, 650000, 10000);
insert into Xuat_chitiet (MaHDX, MaSP, SLXH, ThanhTienXH, GiaXuat)
VALUES ('HDN_01001', 'SP_000128', 50, 60000, 10000);
insert into Xuat(MaHDX,NgayXH,TongTienXH,MaKH,MaNV)
values ('HDX_01001','2024-10-20',0,'KH_01001','NV_00005')
select * from Nhap
SELECT *
FROM Nhap_ChiTiet
WHERE MaHDN = 'HDN_01001' AND MaSP = 'SP_00000'
select * from Nhap_chitiet
where masp='SP_000128'
select * from Xuat_chitiet
where masp='SP_000128'

--- Module 4 Bán hàng---
go
create or alter proc BanHang(@MaSP nvarchar(10),@SLYC numeric)
as
begin
	declare @SLHT numeric, @tt nvarchar(60)
	if @MaSP is null or @MaSP=' ' and @SLYC is null or @SLYC<=0
		print N'Giao dịch không hợp lệ' 
    if not exists (select 1 from SanPham where MaSP = @MaSP )
    begin
        print N'Không có sản phẩm này này trong hệ thống'
        return
    end
	else
	begin
		set @SLHT= (select sum(SLHT) from kho join Chua on kho.MaLH=Chua.MaLH
									 where MaSP=@MaSP)
		if @SLHT <@SLYC
		begin
			print N'Không đủ số lượng hàng để bán'
			print N'Yêu cầu nhập hàng'
		end
		else
			print N'Có đủ số lượng hàng'
			update Kho
			set SLHT=@SLHT-@SLYC
			from chua join Kho on Chua.MaLH=Kho.MaLH
			where @MaSP=MaSP
	end
end
go 

--Module 5 inHDNO---
go
create or alter proc InHDNo
as
begin
    declare @ngayhethan date
    set @ngayhethan = dateadd(month,1,getdate())
    select HDNoNPP.MaDNo, HGD, TTGD, (TongTienNH-STTT) as SoTienConNo
    from HDNoNPP join Nhap on HDNoNPP.MaDNo=Nhap.MaDNo
    where (HGD between getdate() and @ngayhethan)
        and TTGD = N'Chưa hoàn thành'
end
exec InHDNo

--- Module6 Thống kê--
go
create or alter function ThongKe()
returns @bangthongke table (Ngay date,
                            DoanhThu float,
                            ChiPhi float,
                            LoiNhuan float
                            )
as
begin
    declare @ngay date = getdate()
    declare @doanhthu float
    set @doanhthu = isnull((select sum(TongTienXH) 
                    from Xuat
                    where month(NgayXH) = month(@ngay)
                    and year(NgayXH) = year(@ngay)
                    ),0)
    declare @chiphi float
    set @chiphi = isnull((select sum(TongTienNH) 
                    from Nhap
                    where month(NgayNH) = month(@ngay)
                    and year(NgayNH) = year(@ngay)
                    ),0)
    declare @loinhuan float
    set @loinhuan = @doanhthu - @chiphi
    
    insert into @bangthongke (Ngay, DoanhThu, ChiPhi, LoiNhuan)
    values (@ngay, @doanhthu, @chiphi, @loinhuan)
    return
end
go

select * from dbo.ThongKe()


---Module 7 ThemKH---
go
Create  or alter procedure ThemKH (
    @tenkh nvarchar(30),
    @sdt nchar(10),
    @diachi nvarchar(50)
)
As
Begin
    -- kiểm tra dữ liệu đầu vào
    If @tenkh is null or @tenkh = ' ' or
       @sdt is null or @sdt = ' ' or
       @diachi is null or @diachi = ' ' or
       Len(@sdt) <> 10 
    Begin
        -- thông báo lỗi nếu dữ liệu không hợp lệ
        Print N'Thông tin không hợp lệ'
        Return
    End
    -- kiểm tra sđt đã tồn tại chưa
    If exists (select 1 from khachhang where sdt_kh = @sdt)
    Begin
        -- thông báo lỗi nếu sđt đã tồn tại
        Print N'Khách hàng đã tồn tại'
        Return
    End
	else
        begin
			declare @makh nvarchar(10)
			declare @dauso table (dauso char(3));
			IF @makh IS NULL OR @makh = ' '
			BEGIN
				SET @makh = dbo.TaoMa(N'KhachHang'); -- Gọi hàm để tạo mã mới
			END
            insert into @dauso values ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), 
                                           ('036'), ('035'), ('034'), ('033'), ('032'), ('091'), ('094'), 
                                           ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), ('070'), 
                                           ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

                -- Kiểm tra đầu số hợp lệ
			IF NOT EXISTS (SELECT 1 FROM @dauso WHERE dauso = LEFT(@sdt, 3))
				BEGIN
					PRINT N'Đầu số điện thoại không hợp lệ';
					RETURN;
				END
			END
    -- thêm khách hàng mới
	Insert into khachhang (makh, tenkh, sdt_kh, dc_kh)
	Values (@makh, @tenkh, @sdt, @diachi)
    Print N'Đã thêm khách hàng thành công'
End
go
Exec ThemKH  @tenkh = N'Huynh Tan Phát', @sdt = '0386823804', 
@diachi = N'123 đường a, quận b';
Exec ThemKH  @tenkh = ' ', @sdt = ' ', @diachi = ' ';
delete from KhachHang
where TenKH like  N'Huynh Tan Phát'

-- Module 8 Them NV--
go
create or alter proc ThemNV @sdt char(10),
                            @vitri nvarchar(50),
                            @ten nvarchar(50)
as
begin
    if exists (select 1 from NhanVien where SDT_NV = @sdt)
    begin
        print N'Số điện thoại đã tồn tại'
        return
    end
    else
    begin
        -- Bảng tạm chứa các đầu số hợp lệ
        declare @dauso table (dauso char(3));
        insert into @dauso values ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), 
                                   ('036'), ('035'), ('034'), ('033'), ('032'), ('091'), ('094'), 
                                   ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), ('070'), 
                                   ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

        -- Kiểm tra đầu số hợp lệ
        if not exists (select 1 from @dauso where dauso = left(@sdt,3))
        begin
            print N'Số điện thoại không hợp lệ'
            return
        end
    end
    declare @bangvitri table (vitri nvarchar(50))
    insert into @bangvitri values (N'Quản lý'), (N'Nhân viên thu ngân'), (N'Nhân viên bán hàng'), (N'Nhân viên kho')
    if not exists (select 1 from @bangvitri where vitri = @vitri)
    begin
        print N'Vị trí này không có trong hệ thống'
        return
    end

    if @ten is null or @ten = ' '
    begin
        print N'Tên nhân viên không hợp lệ'
        return
    end
    declare @manv char(9)
    set @manv = (select dbo.TaoMa('NhanVien'))
    insert into NhanVien values (@manv, @ten, @sdt, @vitri )
end

--Test--
exec ThemNV @ten = 'Nhân viên 1002', @sdt = '0863456889', @vitri = 'Nhân viên kho'
select * from NhanVien

---Module 9 Them HDNhap--
go
create or alter proc ThemHDN
(
    @sdt nvarchar(10),
    @manv nvarchar(10),
    @manpp nchar(9),
    @tennpp nvarchar(50),
    @dcnpp nvarchar(50)
)
as
begin
    declare @tongtiennh float = 0
    declare @ngaynh date,
            @mahdn nchar(19),
            @madno nchar(9) -- Đổi thành nchar(9) cho nhất quán với bảng HDNoNPP
    declare @vitri nvarchar(50);
    select @vitri = vitri from nhanvien where manv = @manv;
    if not exists (select 1 from nhanvien where manv = @manv) 
    begin
        print N'Không có nhân viên này';
        return;
    end
    else if @vitri not like '%kho'
    begin
        print N'Không hợp lệ';
        return;
    end
    if exists (select 1 from NhaPhanPhoi where SDT_NPP = @sdt)
    begin
        set @manpp = (select manpp from NhaPhanPhoi where SDT_NPP = @sdt);
    end
    else 
    begin
        set @manpp = dbo.Taoma('NhaPhanPhoi'); 
        insert into NhaPhanPhoi (MaNPP, TenNPP, SDT_NPP, DC_NPP)
        values (@manpp, @tennpp, @sdt, @dcnpp);
    end

    -- Thêm hóa đơn nhập
    set @mahdn = dbo.Taoma('Nhap'); 
    set @ngaynh = getdate();
    declare @hgd date
    set @hgd = dateadd(month, 6, @ngaynh)
    
    -- Tạo mã đơn nợ mới
    set @madno = dbo.TaoMa('HDNoNPP');
    
    -- Chèn dữ liệu vào bảng HDNoNPP
    insert into HDNoNPP (MaDNo, HGD, STTT, TTGD)
    values (@madno, @hgd, @tongtiennh, N'Chưa hoàn thành'); -- Thay đổi TTGD nếu cần

    -- Chèn dữ liệu vào bảng Nhap
    insert into nhap (mahdn, manpp, manv, madno, ngaynh, tongtiennh)
    values (@mahdn, @manpp, @manv, @madno, @ngaynh, @tongtiennh);
end
--Test---
exec ThemHDN 
    @sdt = '0386823004',
    @manv = 'NV_000002',
    @manpp = 'NPP_00101',
    @tennpp = 'NhaPhanPhoi1001',
    @dcnpp = 'DC_NPP1001'


select * from NhaPhanPhoi
select * from Nhap
select * from HDNoNPP
select * from nhanvien

---Module 10 Thêm Hóa đon xuất
go
create or alter proc ThemHDX
(		
			@sdt nvarchar(10),@Manv nvarchar(10),
			@ten nvarchar(50), @diachi nvarchar(50)
)
as
begin
	declare @NgayXH date,
			@MaHDX nvarchar(10),
			@TongtienXH float=0,
			@thanhtien float;
	declare @makh nvarchar(10)
	declare @ViTri nvarchar(50);
    select @ViTri = ViTri from NhanVien where MaNV = @MaNV;
	IF not EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @Manv) 
	BEGIN
		PRINT N'Không có nhân viên này';
	END
	else if @ViTri not like N'%[thu ngân,bán hàng]'
	begin
		print N'Không hợp lệ'
	end
	if  EXISTS (SELECT 1 FROM KhachHang WHERE SDT_KH = @SDT)
	begin
		set @makh = (select MaKH from KhachHang where SDT_KH = @SDT);
		set @MaHDX=dbo.TaoMa('Xuat')
		set @NgayXH=getdate()
	end
	else 
	begin
			set @makh=dbo.TaoMa('KhachHang')
			insert into KhachHang( MaKH,TenKH,SDT_KH,DC_KH)
			values (@makh,@ten,@sdt,@diachi)
			--Hóa đơn mới
			set @MaHDX=dbo.TaoMa('Xuat')
			set @NgayXH=getdate()
       end
	   insert into Xuat (MaHDX,NgayXH,MaKH,MaNV,TongTienXH)
	   values (@MaHDX,@NgayXH,@makh,@Manv,@TongtienXH)
end
go
	
exec ThemHDX @sdt ='0386823504',
			 @Manv ='NV_000003',
             @ten = 'Khách 1002',
             @diachi = '123 Địa chỉ'
	
delete  from xuat
where MaHDX  like 'HDX_01001'
select * from NhanVien
select * from KhachHang
select * from xuat


----Module 11 Thêm XCT--
go
CREATE OR ALTER PROCEDURE ThemXuatCT
    @mahdx NVARCHAR(10),
    @SLXH INT,
    @masp NVARCHAR(10)
AS
BEGIN
    DECLARE @thanhtien FLOAT;
    DECLARE @gx FLOAT;
    DECLARE @km FLOAT;

    -- Kiểm tra các điều kiện đầu vào
    IF @mahdx IS NULL OR LTRIM(RTRIM(@mahdx)) = '' 
        OR @SLXH <= 0 OR @SLXH IS NULL
        OR @masp IS NULL OR LTRIM(RTRIM(@masp)) = ''
    BEGIN
        PRINT N'Lỗi'
    END
    IF NOT EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @masp)
    BEGIN
        PRINT N'Không tồn tại sản phẩm'
        RETURN;  
    END
    -- Lấy giá xuất và khuyến mãi
    SELECT @km = KM, @gx = GiaXuat FROM Xuat_chitiet WHERE MaSP = @masp;
    -- Tính thành tiền
    SET @thanhtien = @SLXH * @gx;

    -- Thêm vào bảng Xuat_chitiet
    INSERT INTO Xuat_chitiet (MaHDX, MaSP, ThanhtienXH, SLXH, KM, GiaXuat)
    VALUES (@mahdx, @masp, @thanhtien, @SLXH, @km, @gx);

    -- Cập nhật tổng tiền trong bảng Xuat
    UPDATE Xuat
    SET TongTienXH = ISNULL(TongTienXH, 0) + @thanhtien
    WHERE MaHDX = @mahdx;
	declare @SLHT float
	exec BanHang @masp=@masp,@slyc=@slxh
    PRINT N'Thêm hóa đơn xuất thành công';
END
GO

---Test--
go
select * from Kho join Chua on chua.MaLH=kho.MaLH
where  MaSP ='SP_000006'
exec ThemXuatCT
    @mahdx ='HDX_01001',
    @SLXH =2,
    @masp ='SP_000006'
exec ThemXuatCT
    @mahdx ='HDX_01001',
    @SLXH =8,
    @masp ='SP_000006'
exec ThemXuatCT
    @mahdx ='HDX_01001',
    @SLXH =2,
    @masp ='SP_000010'
	select * from Xuat_chitiet
	where MaHDX='HDX_01001'
	select * from xuat
	where MaHDX='HDX_01001'


---- Module 13 Them NPP
go
Create  or alter procedure ThemNPP 
(
    @tennpp nvarchar(50),
    @sdt_npp nchar(10),
    @dc_npp nvarchar(100)
)
As
Begin
    -- kiểm tra dữ liệu đầu vào
    If @tennpp is null or @tennpp = ' ' or
       @sdt_npp is null or @sdt_npp = ' ' or
       @dc_npp is null or @dc_npp = ' ' or
       Len(@sdt_npp) <> 10 
    Begin
        Print N'Thông tin không hợp lệ'
        Return
    End
	    -- kiểm tra sđt đã tồn tại chưa
    If exists (select 1 from nhaphanphoi where SDT_NPP = @sdt_npp)
    Begin
        Print N'Nhà phân phối đã tồn tại'
        Return
    End
		declare @manpp nvarchar(10)
		IF @manpp IS NULL OR @manpp = ' '
		BEGIN
			SET @manpp = dbo.TaoMa(N'NhaPhanPhoi'); -- Gọi hàm để tạo mã mới
		END
		declare @dauso table (dauso char(3));
		insert into @dauso values   ('086'), ('096'), ('097'), ('098'), ('039'), ('038'), ('037'), 
                                    ('036'), ('035'), ('034'), ('033'), ('032'), ('091'), ('094'), 
                                    ('088'), ('083'), ('084'), ('085'), ('081'), ('082'), ('070'), 
                                    ('079'), ('077'), ('076'), ('078'), ('089'), ('090'), ('093');

                -- Kiểm tra đầu số hợp lệ
			IF NOT EXISTS (SELECT 1 FROM @dauso WHERE dauso = LEFT(@sdt_npp, 3))
				BEGIN
					PRINT N'Đầu số điện thoại không hợp lệ';
					RETURN;
			END
    -- thêm khách hàng mới
    Insert into nhaphanphoi (manpp, tennpp, sdt_npp, dc_npp)
    Values (@manpp, @tennpp, @sdt_npp, @dc_npp)
    Print N'Đã thêm nhà phân phối thành công'
End
go

--Test--
go
exec ThemNPP 
    @tennpp =N'Nhà phân phối m',
    @sdt_npp ='0386823002',
    @dc_npp ='njđ'
---

--Thêm sản phẩm
go 
create or alter proc ThemSP
(
    @masp char(9),
    @tensp nvarchar(50),
    @donvi nvarchar(20),
    @loaihang nvarchar(5)
)
as 
begin
    if exists (select 1 from SanPham where MaSP = @masp)
    begin
        print N'Sản phẩm đã tồn tại'
        return
    end
    set @masp = dbo.TaoMa('SanPham')
    if @tensp is null or @tensp = ''
        or @donvi is null or @donvi = ''
        or @loaihang is null or @loaihang = ''
        return
    if exists (select 1 from SanPham where TenSP = @tensp)
    begin
        print N'Sản phẩm đã tồn tại'
        return
    end
    insert into SanPham (MaSP, TenSP, DonVi, LoaiHang)
    values (@masp, @tensp, @donvi, @loaihang)
end

exec ThemSP @masp = '', @tensp = N'SP_LT254', @donvi = N'Hộp', @loaihang = N'LT'

--NhapHang
go
create or alter proc NhapHang(@MaSP nvarchar(10),@SLN numeric)
as
begin
	if @MaSP is null or @MaSP=' ' and @SLN is null or @SLN<=0
		print N'Giao dịch không hợp lệ'
	declare @SLHT numeric, @tt nvarchar(60) 
    if not exists (select 1 from SanPham where MaSP = @MaSP )
    begin
        print N'Không có sản phẩm này này trong hệ thống'
        return
    end
	else
	begin
		set @SLHT= (select sum(SLHT) from kho join Chua on kho.MaLH=Chua.MaLH
										where MaSP=@MaSP)

		if @SLHT >30
		begin
			print N'Còn hàng'
		end
		else
			print N'Nhập hàng'
			update Kho
			set SLHT=@SLHT+@SLN
			from chua join Kho on Chua.MaLH=Kho.MaLH
			where @MaSP=MaSP
	end
end
go 
--test---
exec NhapHang @MaSP='SP_000006',@SLN= 5
select * from Kho
join Chua on kho.MaLH=Chua.MaLH
where MaSP='SP_000006'


----Nhạp chi tiết
go
CREATE OR ALTER PROCEDURE ThemNhapCT
(   
	@mahdn NVARCHAR(10),
    @SLNH INT,
    @masp NVARCHAR(10)
)
AS
BEGIN
    DECLARE @thanhtien FLOAT;
    DECLARE @gn FLOAT;
    IF @mahdn IS NULL OR LTRIM(RTRIM(@mahdn)) = '' 
        OR @SLNH <= 0 OR @SLNH IS NULL
        OR @masp IS NULL OR LTRIM(RTRIM(@masp)) = ''
    BEGIN
        PRINT N'Lỗi'
    END
    IF  EXISTS (SELECT 1 FROM SanPham WHERE MaSP = @masp)
    BEGIN
		SELECT @gn = GiaNhap FROM Nhap_chitiet WHERE MaSP = @masp;
		-- Tính thành tiền
		SET @thanhtien = @SLNH * @gn;

		-- Thêm vào bảng Xuat_chitiet
		INSERT INTO Nhap_chitiet(MaHDN, MaSP, ThanhtienNH, SLNH,GiaNhap)
		VALUES (@mahdn, @masp, @thanhtien, @SLNH,@gn);

		-- Cập nhật tổng tiền trong bảng Xuat
		UPDATE Nhap
		SET TongTienNH = ISNULL(TongTienNH, 0) + @thanhtien
		WHERE MaHDN = @mahdn;
		exec NhapHang @MaSP=@masp, @SLN=@SLNH 
		PRINT N'Thêm hóa đơn xuất thành công';
		end
END
GO

--Test--
go
select * from Nhap_chitiet
where masp ='SP_000006' 
select * from Kho join Chua on chua.MaLH=kho.MaLH
where  MaSP ='SP_000006'
exec ThemNhapCT
    @maHDN='HDN_01001',
    @SLNH =4,
    @masp ='SP_000128'

