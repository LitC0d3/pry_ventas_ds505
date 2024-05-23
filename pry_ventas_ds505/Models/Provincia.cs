using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace pry_ventas_ds505.Models
{
    [Table("PROVINCIA")]
    public class Provincia
    {
        [Key]
        [StringLength(4)]
        public string IdProvincia { get; set; }

        [Required(ErrorMessage = "La descripción es obligatoria.")]
        [StringLength(45)]
        public string Descripcion { get; set; }

        [Required(ErrorMessage = "El ID del departamento es obligatorio.")]
        [StringLength(2)]
        public string IdDepartamento { get; set; }
    }
}
