using System.Data;
using Microsoft.Data.SqlClient;
using System.Globalization;

string cadenaConexion = Environment.GetEnvironmentVariable("MUNDIAL_CS") // La cadena de conexion como variable de entorno
    ?? throw new InvalidOperationException("Falta la variable MUNDIAL_CS");

using SqlConnection conexion = new SqlConnection(cadenaConexion);   // 'using' cierra la conexión al salir (como un cleanup)

try
{
    conexion.Open();
}
catch (SqlException excepcionSql)
{
    Console.WriteLine($"Error en la conexion a SQL Server:\n{excepcionSql.Message}");
    return;
}

while (true)
{
    Console.WriteLine("\n1) Alta  2) Modificar  3) Baja  0) Salir");
    string opcionSeleccionada = Console.ReadLine() ?? "0";
    if (opcionSeleccionada == "0") break;

    try
    {
        switch (opcionSeleccionada)
        {
            case "1":
                int nuevoId = Alta(conexion, Pedir("Nombre"), PedirFecha(), Pedir("Posicion (ARQ/DEF/MED/DEL)"), PedirOpcional("Club"));
                Console.WriteLine($"Jugador creado con id {nuevoId}");
                break;
            case "2":
                Modificar(conexion, int.Parse(Pedir("Id")), Pedir("Nombre"), PedirFecha(), Pedir("Posicion"), PedirOpcional("Club"));
                Console.WriteLine("Modificado.");
                break;
            case "3":
                Baja(conexion, int.Parse(Pedir("Id")));
                Console.WriteLine("Eliminado.");
                break;
        }
    }
    catch (SqlException excepcionSql)
    {
        Console.WriteLine($"Error {excepcionSql.Number}:\n{excepcionSql.Message}");
    }
    catch (FormatException)
    {
        Console.WriteLine("Dato con formato inválido.");
    }
}

static SqlCommand CrearComandoProcedimiento(SqlConnection conexion, string nombre) =>
    new SqlCommand(nombre, conexion) { CommandType = CommandType.StoredProcedure };

static int Alta(SqlConnection conexion, string nombre, DateTime fecha, string pos, string? club)
{
    using var cmd = CrearComandoProcedimiento(conexion, "torneo.sp_jugador_alta");
    cmd.Parameters.Add("@nombre", SqlDbType.NVarChar, 150).Value = nombre;
    cmd.Parameters.Add("@fechaNacimiento", SqlDbType.Date).Value = fecha;
    cmd.Parameters.Add("@posicion", SqlDbType.VarChar, 10).Value = pos;
    cmd.Parameters.Add("@clubOrigen", SqlDbType.NVarChar, 100).Value = (object?)club ?? DBNull.Value;
    var id = cmd.Parameters.Add("@jugadorId", SqlDbType.Int);
    id.Direction = ParameterDirection.Output;          // parámetro OUTPUT del SP
    cmd.ExecuteNonQuery();
    return (int)id.Value;
}

static void Modificar(SqlConnection conexion, int id, string nombre, DateTime fecha, string pos, string? club)
{
    using var cmd = CrearComandoProcedimiento(conexion, "torneo.sp_jugador_modificacion");
    cmd.Parameters.Add("@jugadorId", SqlDbType.Int).Value = id;
    cmd.Parameters.Add("@nombre", SqlDbType.NVarChar, 150).Value = nombre;
    cmd.Parameters.Add("@fechaNacimiento", SqlDbType.Date).Value = fecha;
    cmd.Parameters.Add("@posicion", SqlDbType.VarChar, 10).Value = pos;
    cmd.Parameters.Add("@clubOrigen", SqlDbType.NVarChar, 100).Value = (object?)club ?? DBNull.Value;
    cmd.ExecuteNonQuery();
}

static void Baja(SqlConnection conexion, int id)
{
    using var cmd = CrearComandoProcedimiento(conexion, "torneo.sp_jugador_baja");
    cmd.Parameters.Add("@jugadorId", SqlDbType.Int).Value = id;
    cmd.ExecuteNonQuery();
}

static string Pedir(string etiqueta) { Console.Write(etiqueta + ": "); return Console.ReadLine() ?? ""; }
static string? PedirOpcional(string etiqueta) { var s = Pedir(etiqueta + " (vacío = ninguno)"); return s == "" ? null : s; }
static DateTime PedirFecha() =>
    DateTime.ParseExact(
        Pedir("Fecha de nacimiento (yyyy-MM-dd)"),
        "yyyy-MM-dd",
        CultureInfo.InvariantCulture
    );