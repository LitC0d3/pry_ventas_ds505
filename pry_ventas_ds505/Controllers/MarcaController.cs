using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using System.Linq;

namespace pry_ventas_ds505.Controllers
{
    public class MarcaController : Controller
    {
        private readonly ApplicationDbContext _context;

        public MarcaController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var marcas = _context.Marcas.ToList();
            return View(marcas);
        }
    }
}
