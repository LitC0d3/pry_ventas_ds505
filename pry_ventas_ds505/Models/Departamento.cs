using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace pry_ventas_ds505.Models
{
    [Table("DEPARTAMENTO")]
    public class Departamento
    {
        [Key]
        [StringLength(2)]
        public string IdDepartamento { get; set; }

        [Required]
        [StringLength(45)]
        public string Descripcion { get; set; }
    }
}