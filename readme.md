LƯU Ý: Sau khi clone về thì OPEN WITH NOTEPAD++ hoặc vsCode để Edit các dự kiên sau (Khi chạy với powershell thì chạy trên cùng 1 folder để code tạo đúng file)

Đối với CodeChung.ps1:
+ Chỉnh sửa dòng 18: Thay đổi connectionstring để kết nối với cơ sở dữ liệu của bạn.
+ Chỉnh sửa dòng 170 và 291: Nếu bạn đã đổi Dbcontext thành tên khác, hãy đổi tên Dbcontext ở các dòng này.
+ Chỉnh sửa dòng 251: Thay đổi tên Entity (đối tượng) phù hợp với account của bạn.
+ Chỉnh sửa dòng 255, 256, 257: Điều chỉnh các trường (fields) để phù hợp với bảng (table) đã chỉ định ở dòng 251.
+ Chỉnh sửa dòng 394: Điều chỉnh tên Entity (đối tượng) phù hợp với mối quan hệ (relationship) đã chỉ định.
+ Sau khi đã chỉnh sửa những phần trên, mở file Dbcontext đã entity và sửa đoạn mã sau:
	protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            IServiceCollection services;
            var builder = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("appsettings.json", optional: true, reloadOnChange: true);
            IConfigurationRoot configuration = builder.Build();
            string connec = configuration.GetConnectionString("MyDB");
            optionsBuilder.UseSqlServer(connec);
        }
Sau khi đổi những cái trên có thể Run with powershell



Đối với CodeRiengDAO.ps1
	+Mở lên và đổi các bảng và mối quan hệ cho phù hợp với db cà đề bài yêu cầu
	+Ở đây tùy thuộc vào thao tác và thông thường tôi nhấn ctrl+H đề thay thế code và tìm kiếm thao tác nhanh hơn
Sau khi đổi những cái trên tiếp tục Run with powershell



Đối với CodeRiengRepo.ps1 
	+Tương tự như CodeRiengDAO.ps1 có thể thay thế tất cả thuộc tính với điều kiện check chữ hoa và chữ thường
Sau khi đổi những cái trên tiếp tục Run with powershell
	

Đối với CodeRiengController.ps1 
 	+sau khi thay thế tất cả thuộc tính với điều kiện check chữ hoa và chữ thường
	+vào program.cs line 432 add thêm scope với codeRiengRepo đã chạy 
Sau khi đổi những cái trên tiếp tục Run with powershell

Import TestCase.Postman_collection.json vào thay đổi url và body cho phù hợp => sau đó run collection để chạy test trong tests tab 

<img src="https://user-images.githubusercontent.com/90783531/255421132-a5791677-e5ab-4ac8-a064-7450e430c2d7.png" width="300"/>
