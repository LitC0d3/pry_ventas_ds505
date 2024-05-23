using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using System.Linq;

namespace pry_ventas_ds505.Controllers
{
    public class DistritoController : Controller
    {
        private readonly ApplicationDbContext _context;

        public DistritoController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var distritos = _context.Distritos.ToList();
            return View(distritos);
        }
    }
}