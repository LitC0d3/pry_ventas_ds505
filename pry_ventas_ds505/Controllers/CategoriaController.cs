using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using pry_ventas_ds505.Models;
using System.Linq;

namespace pry_ventas_ds505.Controllers
{
    public class CategoriaController : Controller
    {
        private readonly ApplicationDbContext _context;

        public CategoriaController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var categorias = _context.Categorias.ToList();
            return View(categorias); 
        }
    }
}
