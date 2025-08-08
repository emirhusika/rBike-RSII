using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using rBike.API;
using rBike.API.Filters;
using rBike.Services;
using rBike.Services.BikeStateMachine;
using rBike.Services.Database;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddTransient<IBikeService, BikeService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ICategoryService, CategoryService>();
builder.Services.AddTransient<IMailService, MailService>();
builder.Services.AddTransient<IBikeFavoriteService, BikeFavoriteService>();
builder.Services.AddTransient<IReviewService, ReviewService>();
builder.Services.AddTransient<ICommentService, CommentService>();
builder.Services.AddTransient<IEquipmentService, EquipmentService>();
builder.Services.AddTransient<IEquipmentCategoryService, EquipmentCategoryService>();
builder.Services.AddTransient<IOrderService, OrderService>();
builder.Services.AddTransient<IRoleService, RoleService>();
builder.Services.AddTransient<IReportService, ReportService>();

builder.Services.AddTransient<BaseBikeState>();
builder.Services.AddTransient<InitialBikeState>();
builder.Services.AddTransient<DraftBikeState>();
builder.Services.AddTransient<ActiveBikeState>();
builder.Services.AddTransient<HiddenBikeState>();

builder.Services.AddTransient<IReservationService, ReservationService>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
})
.AddJsonOptions(options =>
{
    options.JsonSerializerOptions.ReferenceHandler = System.Text.Json.Serialization.ReferenceHandler.IgnoreCycles;
    options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.CamelCase;
    options.JsonSerializerOptions.DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull;
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

});


var connectionString = builder.Configuration.GetConnectionString("rBikeConnection");

builder.Services.AddDbContext<RBikeContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();
rBike.Services.Mappings.MapsterConfig.RegisterMappings();
builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthentication();  
app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<RBikeContext>();
    dataContext.Database.Migrate();

}

app.Run();
