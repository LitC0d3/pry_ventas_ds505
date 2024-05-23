using Microsoft.EntityFrameworkCore;
using pry_ventas_ds505.Models;

namespace pry_ventas_ds505.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {
        }
        public DbSet<Producto> Productos { get; set; }
        public DbSet<Usuario> Usuario { get; set; }
        public DbSet<Marca> Marcas { get; set; }
    }
}
