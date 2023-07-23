dotnet new sln -n PE_PRN231_SU23_NGUYENVANQUANG_SE150550
# BussinessObject ------------------------------------------------------------------------
dotnet new classlib -n BusinessObject -f net6.0
dotnet sln PE_PRN231_SU23_NGUYENVANQUANG_SE150550.sln add BusinessObject/BusinessObject.csproj
cd BusinessObject
Remove-Item -Path "Class1.cs"
dotnet add package CoreApiResponse --version 1.0.1
dotnet add package Microsoft.AspNetCore.Authentication.JwtBearer --version 6.0.14
dotnet add package Microsoft.AspNetCore.OData --version 8.2.0
dotnet add package Microsoft.EntityFrameworkCore.Design --version 6.0.14
dotnet add package Microsoft.EntityFrameworkCore.SqlServer --version 6.0.14
dotnet add package Microsoft.EntityFrameworkCore.Tools --version 6.0.14
dotnet add package Microsoft.Extensions.Configuration --version 6.0.1
dotnet add package Microsoft.Extensions.Configuration.Json --version 6.0.0
dotnet add package Swashbuckle.AspNetCore.Filters --version 6.1.0
dotnet build
#========================================================================================TODO change Database Petshop2023DB
dotnet ef dbcontext scaffold "Server=localhost;Database=PetShop2023DB;User Id=sa;Password=1234567890;Trusted_Connection=True;" Microsoft.EntityFrameworkCore.SqlServer -o Model

mkdir Authortication
cd Authortication
@"
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BusinessObject.Authortication
{
    public class PermissionAuthorizeAttribute : AuthorizeAttribute, IAuthorizationFilter
    {
        private string[] _roles;
        public PermissionAuthorizeAttribute(params string[] roles)
        {
            this._roles = roles;
        }
        public void OnAuthorization(AuthorizationFilterContext context)
        {
            if (context.HttpContext.User.Identity.IsAuthenticated)
            {

                var roleClaim = context.HttpContext.User.Claims.FirstOrDefault(x => x.Type.ToLower() == "role");
                if (roleClaim != null && this._roles.FirstOrDefault(x => x.Trim().ToLower().Equals(roleClaim.Value.Trim().ToLower())) == null)
                {
                    context.Result = new ObjectResult("Forbidden") { StatusCode = 403, Value = "You are not allowed to access this function!" };
                }
                else
                {
                    return;
                }
            }
            else
            {
                context.Result = new StatusCodeResult(401);
            }
        }

    }
}
"@ | Out-File -FilePath "PermissionAuthorizeAttribute.cs" -Encoding UTF8
cd ..
mkdir DTO
cd DTO
mkdir Request
cd Request
@"
using System;

namespace BusinessObject.DTO.Request
{
    public class LoginModel
    {
        public string MemberId { get; set; }
        public string Password { get; set; }
    }
}
"@ | Set-Content -Path "LoginModel.cs"

cd ..
cd ..
cd ..


# DataAccess -------------------------------------------------------------------------------------------------------------
dotnet new classlib -n DataAccess -f net6.0
dotnet sln PE_PRN231_SU23_NGUYENVANQUANG_SE150550.sln add DataAccess/DataAccess.csproj
cd DataAccess
dotnet add reference ..\BusinessObject\BusinessObject.csproj
Remove-Item -Path "Class1.cs"
mkdir GlobalExceptionHandler
cd GlobalExceptionHandler
#Create class DataAccess.GlobalExceptionHandler ==============
@"
using System.Net;

namespace DataAccess.GlobalExceptionHandler
{
    public class ExceptionResponse
    {
        public string Type { get; set; }
        public string Message { get; set; }
        public string StackTrace { get; set; }
        public bool Status { get; set; }
        public int StatusCode { get; set; }

        public ExceptionResponse(Exception ex)
        {
            Type = ex.GetType().Name;
            Message = ex.Message;
            Status = false;
            StackTrace = ex.ToString();
            StatusCode = 500;
            if (ex is HttpStatusException httpException)
            {
                //this.StatusCode = httpException.Status.ToString();
                this.StatusCode = (int)httpException.Status;
            }
        }

        public class HttpStatusException : Exception
        {
            public HttpStatusCode Status { get; set; }
            public HttpStatusException(HttpStatusCode code, string msg) : base(msg)
            {
                this.Status = code;
            }
        }
    }
}
"@ | Set-Content -Path "GlobalExceptionHandler.cs"
cd ..
#AuthenticateDao
@"
using BusinessObject.DTO.Request;
using BusinessObject.Model;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DataAccess
{
    public class AuthenticateDao
    {
        private static AuthenticateDao instance = null;
        private static readonly object instanceLock = new();
        private AuthenticateDao() { }
        public static AuthenticateDao Instance
        {
            get
            {
                lock (instanceLock)
                {
                    instance ??= new AuthenticateDao();
                    return instance;
                }
            }
        }

        public PetShopMember Login(LoginModel loginModel)
        {
            PetShopMember member = null;
            try
            {
                using var context = new PetShop2023DBContext();//=========================Todo change DbContext x.MemberId and change x.Id
                var mem = context.PetShopMembers.SingleOrDefault(x => x.MemberId == loginModel.MemberId && x.MemberPassword == loginModel.Password);
                if (mem != null)
                {
                    member = mem;
                }
            }
            catch (Exception ex)
            {
                throw new Exception(ex.Message);
            }
            return member;
        }
    }
}
"@ | Set-Content -Path "AuthenticateDao.cs"
cd ..


# Repositories -------------------------------------------------------------------------------------------------------------
dotnet new classlib -n Repositories -f net6.0
dotnet sln PE_PRN231_SU23_NGUYENVANQUANG_SE150550.sln add Repositories/Repositories.csproj
cd Repositories
dotnet add reference ..\BusinessObject\BusinessObject.csproj
dotnet add reference ..\DataAccess\DataAccess.csproj
Remove-Item -Path "Class1.cs"
#IAuthenRepository ============
@"
using BusinessObject.DTO.Request;
namespace Repositories
{
    public interface IAuthenRepository
    {
        string Login(LoginModel loginModel);
    }
}
"@ | Set-Content -Path "IAuthenRepository.cs"

#AuthenRepository =====
@"
using BusinessObject.DTO.Request;
using BusinessObject.Model;
using DataAccess;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace Repositories
{
    public class AuthenRepository : IAuthenRepository
    {
        private readonly IConfiguration configuration;
        public AuthenRepository(IConfiguration configuration)
        {
            this.configuration = configuration;
        }

        public string Login(LoginModel loginModel)
        {
            string result;
            var member = AuthenticateDao.Instance.Login(loginModel);
            if (member == null)
            {
                return "UnAuthenticate";
            }
            switch (member.MemberRole)
            {
                case 2: result = GenerateToken(member);
                    break;
                default: result = "UnAuthortication";
                    break;
            }
            return result;
        }

        public string GenerateToken(PetShopMember mem)//====================CHAGE CLASS ENTITY
        {
            List<Claim> claims = new List<Claim>
            {
                new Claim(ClaimTypes.Name,mem.FullName),//====================CHAGE FIELD ENTITY
                new Claim(ClaimTypes.Email,mem.EmailAddress),//====================CHAGE FIELD ENTITY
                new Claim(ClaimTypes.Role, "Staff")//====================CHAGE FIELD ENTITY
            };

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(configuration.GetSection("Jwt:Key").Value));
            var credential = new SigningCredentials(key, SecurityAlgorithms.HmacSha512);
            var token = new JwtSecurityToken(
                    claims: claims,
                    expires: DateTime.Now.AddMinutes(configuration.GetValue<int>("Jwt:ExpirationInMinutes")),
                    signingCredentials: credential
                    );
            var jwtToken = new JwtSecurityTokenHandler().WriteToken(token);
            return jwtToken;
        }
    }
}
"@ | Set-Content -Path "AuthenRepository.cs"
cd ..

# WebApi --------------------------------------------------------------------------------------------------------------------------------
dotnet new webapi -n WebApi -f net6.0
dotnet sln PE_PRN231_SU23_NGUYENVANQUANG_SE150550.sln add WebApi/WebApi.csproj
cd WebApi
dotnet add reference ..\Repositories\Repositories.csproj
#ConnectionString=============
$appsettingsContent = Get-Content -Path "appsettings.json" -Raw
$jsonConfig = @{
    "Logging" = @{
        "LogLevel" = @{
            "Default" = "Information"
            "Microsoft.AspNetCore" = "Warning"
        }
    }
    "AllowedHosts" = "*"
    "ConnectionStrings" = @{
        "MyDB" = "Server=(local);uid=sa;pwd=1234567890;database=PetShop2023DB;TrustServerCertificate=True" #===============TODO CHANGE DB
    }
    "Jwt" = @{
        "Issuer" = "your_issuer"
        "Audience" = "your_audience"
        "Key" = "SecretKey9851@h335%7djr"
        "ExpirationInMinutes" = 60
    }
}
$jsonString = $jsonConfig | ConvertTo-Json -Depth 100
$jsonString | Set-Content -Path "appsettings.json"


cd Controllers

# AuthController ==========
@"
using BusinessObject.DTO.Request;
using CoreApiResponse;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Repositories;

namespace WebApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class AuthController : BaseController
    {
        private readonly IAuthenRepository _authenRepository;
        public AuthController(IAuthenRepository authenRepository)
        {
            _authenRepository = authenRepository;
        }

        [HttpPost("login")]
        public IActionResult Login(LoginModel loginModel)
        {
            var result = _authenRepository.Login(loginModel);
            return CustomResult("Get Token Successfully!", result, System.Net.HttpStatusCode.OK);
        }
    }
}
"@ | Set-Content -Path "AuthController.cs"

#ExceptionController =========
@"
using DataAccess.GlobalExceptionHandler;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using static DataAccess.GlobalExceptionHandler.ExceptionResponse;

namespace WebApi.Controllers
{
    [ApiController]
    [ApiExplorerSettings(IgnoreApi = true)]
    public class ExceptionController : ControllerBase
    {
        [Route("exception")]
        public ExceptionResponse Error()
        {
            var context = HttpContext.Features.Get<IExceptionHandlerFeature>();
            var exception = context?.Error; // Your exception
            var code = 500; // Internal Server Error by default

            if (exception is HttpStatusException httpException)
            {
                code = (int)httpException.Status;
            }

            Response.StatusCode = code;

            return new ExceptionResponse(exception); // Your error model
        }
    }
}
"@ | Set-Content -Path "ExceptionController.cs"
cd ..

#Program.cs replace code ===================================TODO replace code
@"
using BusinessObject.Model;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.OData;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OData.ModelBuilder;
using Microsoft.OpenApi.Models;
using Repositories;
using Swashbuckle.AspNetCore.Filters;
using System.Text;

namespace WebApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Add services to the container.

            // Add Odata
            var modelBuilder = new ODataConventionModelBuilder();
            modelBuilder.EntitySet<Pet>("Pets");//============================================TODO CHANGE ENTITY
            builder.Services.AddControllers().AddOData(
            options => options.Select().Filter().OrderBy().Expand().Count().SetMaxTop(null).AddRouteComponents(
            "odata",
            modelBuilder.GetEdmModel()));

            //add securiry swagger
            builder.Services.AddSwaggerGen(options =>
            {
                options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
                {
                    Description = "Enter Your JWT token ",
                    In = ParameterLocation.Header,
                    Name = "Authorization",
                    Type = SecuritySchemeType.ApiKey
                });

                options.OperationFilter<SecurityRequirementsOperationFilter>();
            });

            //add authentication jwt 
            builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    ValidateAudience = false,
                    ValidateIssuer = false,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration.GetSection("Jwt:Key").Value))
                };
            });

            //add CORS
            builder.Services.AddCors();

            //Dependency Injection
            //=============================TODO ADD SCOPE REPOSITORY OF PRODUCT
            builder.Services.AddScoped<IAuthenRepository, AuthenRepository>();

            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();

            //use authentication
            app.UseAuthentication();

            app.UseAuthorization();

            //use exception handler
            app.UseExceptionHandler("/exception");

            //use CORS
            app.UseCors(policy =>
            {
                policy
                    .AllowAnyHeader()
                    .AllowAnyOrigin()
                    .AllowAnyMethod();
            });

            app.MapControllers();

            app.Run();
        }
    }
}
"@ | Set-Content Program.cs -Force
dotnet build
cd ..
