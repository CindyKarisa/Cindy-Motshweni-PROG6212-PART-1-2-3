using System.ComponentModel.DataAnnotations;

public class User
{
    [Key]
    public int Id { get; set; }
    [Required] public string Name { get; set; }
    [Required, EmailAddress] public string Email { get; set; }
    [Required] public string PasswordHash { get; set; }
    [Required] public string Role { get; set; } // "Organiser" or "Participant"
}

public class Event
{
    [Key]
    public int Id { get; set; }
    [Required] public string Name { get; set; }
    public string Description { get; set; }
    [Required] public DateTime Date { get; set; }
    [Required] public string Location { get; set; }
    [Required] public double Distance { get; set; }
    [Required] public string EventType { get; set; } // Run, Walk, Cycle
    public int OrganiserId { get; set; }
    public ICollection<Category> Categories { get; set; }
}

public class Category
{
    [Key]
    public int Id { get; set; }
    [Required] public string Name { get; set; }
    public int EventId { get; set; }
    public Event Event { get; set; }
}

public class Enrolment
{
    [Key]
    public int Id { get; set; }
    public int ParticipantId { get; set; }
    public int EventId { get; set; }
    public int CategoryId { get; set; }
}

public class Result
{
    [Key]
    public int Id { get; set; }
    public int ParticipantId { get; set; }
    public int EventId { get; set; }
    public TimeSpan FinishTime { get; set; }
    public int FinishingPosition { get; set; }
}