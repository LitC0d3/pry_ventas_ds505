using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using pry_ventas_ds505.Models;

namespace pry_ventas_ds505.Controllers
{
    public class PersonalController : Controller
    {
        private readonly ApplicationDbContext _context;

        public PersonalController(ApplicationDbContext context)
        {
            _context = context;
        }
        public IActionResult Index()
        {
            IEnumerable<Personal> ListarPersonal = _context.Personal;

            return View(ListarPersonal);
        }
    }
}
