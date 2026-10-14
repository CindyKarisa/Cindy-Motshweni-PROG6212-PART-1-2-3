using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

[Route("api/[controller]")]
[ApiController]
public class EventsController : ControllerBase
{
    private readonly RaceDayContext _context;

    public EventsController(RaceDayContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetEvents()
    {
        var events = await _context.Events.Include(e => e.Categories).ToListAsync();
        return Ok(events);
    }

    [HttpPost]
    public async Task<IActionResult> CreateEvent([FromBody] Event raceEvent)
    {
        var role = HttpContext.Session.GetString("UserRole");
        if (role != "Organiser")
            return Unauthorized("Only Organisers can create events.");

        _context.Events.Add(raceEvent);
        await _context.SaveChangesAsync();
        return Ok(raceEvent);
    }
}