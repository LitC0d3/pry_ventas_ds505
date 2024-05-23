using Microsoft.AspNetCore.Mvc;
using pry_ventas_ds505.Data;
using pry_ventas_ds505.Models;
using System.Collections.Generic;

namespace pry_ventas_ds505.Controllers
{
    public class UsuarioController : Controller
    {
        private readonly ApplicationDbContext _context;

        public UsuarioController(ApplicationDbContext context)
        {
            _context = context;
        }

        public IActionResult Index()
        {
            IEnumerable<Usuario> ListarUsuarios = _context.Usuario;
            return View(ListarUsuarios);
        }
    }
}
