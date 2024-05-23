using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using pry_ventas_ds505.Models;
using System.Linq;

namespace pry_ventas_ds505.Controllers
{
    public class ProvinciaController : Controller
    {
        private readonly ApplicationDbContext _context;

        public ProvinciaController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var provincias = _context.Provincias.ToList();
            return View(provincias);
        }
    }
}
