using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace pry_ventas_ds505.Models
{
    [Table("PRODUCTO")]
    public class Producto
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        [Display(Name = "ID del Producto")]
        public int IdProducto { get; set; }

        [Required(ErrorMessage = "El nombre es obligatorio")]
        [StringLength(500, ErrorMessage = "El nombre no puede exceder los 500 caracteres")]
        [Display(Name = "Nombre")]
        public string Nombre { get; set; }

        [StringLength(500, ErrorMessage = "La descripción no puede exceder los 500 caracteres")]
        [Display(Name = "Descripción")]
        public string Descripcion { get; set; }

        [ForeignKey("Marca")]
        [Display(Name = "ID de Marca")]
        public int IdMarca { get; set; }

        [ForeignKey("Categoria")]
        [Display(Name = "ID de Categoría")]
        public int IdCategoria { get; set; }

        [Required(ErrorMessage = "El precio es obligatorio")]
        [Range(0, 9999999999.99, ErrorMessage = "El precio debe estar entre 0 y 9999999999.99")]
        [Display(Name = "Precio")]
        public decimal Precio { get; set; }

        [Required(ErrorMessage = "El stock es obligatorio")]
        [Range(0, int.MaxValue, ErrorMessage = "El stock debe ser un número positivo")]
        [Display(Name = "Stock")]
        public int Stock { get; set; }

        [StringLength(100, ErrorMessage = "La ruta de la imagen no puede exceder los 100 caracteres")]
        [Display(Name = "Ruta de la Imagen")]
        public string RutaImagen { get; set; }

        [Display(Name = "Activo")]
        public bool Activo { get; set; } = true;

        [Display(Name = "Fecha de Registro")]
        [DataType(DataType.DateTime)]
        public DateTime FechaRegistro { get; set; } = DateTime.Now;
    }
}
