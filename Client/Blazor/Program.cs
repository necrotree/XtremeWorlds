using Microsoft.Extensions.FileProviders;
using Client.Blazor.Components;
using Client.Blazor.Services;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddScoped<BrowserGameSession>();
builder.Services.AddScoped<BrowserFnaRenderer>();

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}
app.UseStatusCodePagesWithReExecute("/not-found", createScopeForStatusCodePages: true);
// Local development uses HTTP; redirect only when an HTTPS endpoint is configured.
if (!app.Environment.IsDevelopment())
    app.UseHttpsRedirection();

app.UseWebSockets();
app.UseAntiforgery();

// FNA and the browser share the copied artwork; expose it independently of generated static asset manifests.
app.UseStaticFiles(new StaticFileOptions {
    FileProvider = new PhysicalFileProvider(Path.Combine(AppContext.BaseDirectory, "Assets")), RequestPath = "/assets"
});
app.UseStaticFiles(new StaticFileOptions {
    FileProvider = new PhysicalFileProvider(Path.Combine(AppContext.BaseDirectory, "gfx")), RequestPath = "/gfx"
});
app.MapGet("/game-frames/{id}", (HttpContext context, string id) => BrowserFrameStream.ServeAsync(context, id));
app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
