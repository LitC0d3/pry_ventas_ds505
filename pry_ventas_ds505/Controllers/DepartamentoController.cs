using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using pry_ventas_ds505.Models;
using System.Linq;

namespace pry_ventas_ds505.Controllers
{
    public class DepartamentoController : Controller
    {
        private readonly ApplicationDbContext _context;

        public DepartamentoController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            var departamentos = _context.Departamentos.ToList();
            return View(departamentos);
        }
    }
}