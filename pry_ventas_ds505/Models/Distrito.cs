using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace pry_ventas_ds505.Models
{
    [Table("DISTRITO")]
    public class Distrito
    {
        [Key]
        [StringLength(6)]
        public string IdDistrito { get; set; }

        [Required]
        [StringLength(45)]
        public string Descripcion { get; set; }

        [Required]
        [StringLength(4)]
        public string IdProvincia { get; set; }

        [Required]
        [StringLength(2)]
        public string IdDepartamento { get; set; }
    }
}