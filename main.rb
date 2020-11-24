# Si se necesitan librerías, se incluyen acá
require 'singleton'

# Parte 1
class Estrategia
  # No es necesario para polimorfismo
  include Singleton
  def calcular(_pais)
    # Con esto aseguramos que implementen esto
    # Estrategia.new.calcular(Pais.new(...)) da error
    raise 'Definilo, capo'
  end
end

# < == inherits
class PbiPerCapita < Estrategia
  include Singleton
  def calcular(pais)
    # El return es implícito: la última línea es lo que se retorna
    pais.pbi / pais.poblacion
  end
end

class Gini < Estrategia
  def calcular(pais)
    # Los parántesis no son necesarios
    # Es un método o un atributo?
    pais.ingreso_superior / pais.ingreso_inferior
  end
end

class IngresosAltos < Estrategia
  def calcular(pais)
    pais.ingreso_superior
  end
end

class AccesoAUniversidad < Estrategia
  def calcular(pais)
    pais.porcentaje_universitario
  end
end

class Nombrista < Estrategia
  def calcular(pais)
    pais.nombre.size * 10
  end
end

class Pais
  # Metaprograma tanto un setter como un getter
  attr_accessor :nombre, :habitantes, :pbi,
                :porcentaje_universitario, :ingresos_medios
  def initialize(nombre, pbi, habitantes,
                 porcentaje_universitario, ingresos_medios)
    self.nombre = nombre
    self.pbi = pbi
    self.habitantes = habitantes
    self.porcentaje_universitario = porcentaje_universitario
    self.ingresos_medios = ingresos_medios
  end
end

class Mundo
  attr_accessor :paises
  # Al no hacer un initialize, la instanciación es
  # mundo = Mundo.new
  # mundo.paises = [Pais.new(...), ...]
  def el_mejor(estrategia)
    # El bloque no es un parámetro, todo método puede
    # recibir hasta un bloque
    paises.max { |pais| estrategia.calcular(pais) }
  end
end

# Parte 2
class Articulo
  # No tiene lógica, se le conoce como data object
  attr_accessor :titulo, :cifra, :analista

  def initialize(titulo, cifra, analista)
    self.titulo = titulo
    self.cifra = cifra
    self.analista = analista
  end
end

class Periodista
  attr_accessor :articulos, :nombre
  def initialize(nombre)
    self.articulos = []
    self.nombre = nombre
  end

  def escribir_articulo(pais)
    # Append
    articulos << Articulo.new(titulo, cifra(pais), self)
  end
  
  def puede_escribir?(pais)
    # Si un método devuelve booleano, va con signo de pregunta
    (articulos.size < 3) && !nombre.include?(pais.nombre)
  end

  def titulo
    raise 'Definilo, capo'
  end

  def cifra(_pais)
    raise 'Definilo, capo'
  end
end

class Diario
  attr_accessor :periodistas

  # Si un método tiene mucho efecto colateral o 
  # cambia la lista in situ, va con signo de admiración
  def armar_edicion!
    seleccionar_periodistas(pais).each do |periodista|
      periodista.escribir_articulo(pais)
    end
  end

  def seleccionar_periodistas(pais)
    # Si fuera sin parámetro podría ser:
    # periodistas.select(&:puede_escribir?)
    periodistas.select {|periodista| periodista.puede_escribir?(pais)}
  end
end

class Panqueque < Periodista
  attr_accessor :positiva, :negativa, :paises_simpaticos, :nombre

  def initialize(nombre, positiva, negativa, paises_simpaticos)
    # Si pongo sólo super sin parántesis se mandan los mismos
    # parámetros idénticos
    super(nombre)
    self.positiva = positiva
    self.negativa = negativa
    self.paises_simpaticos = paises_simpaticos
  end

  def cifra(pais)
    positiva.calcular(pais) if le_gusta?(pais)
    negativa.calcular(pais)
  end

  def le_gusta?(pais)
    paises_simpaticos.include?(pais)
  end

  def titulo
    # Interpolación de strings
    "La columna económica de #{nombre}"
  end
end

class JuanciPayo < Panqueque
  def le_gusta?(pais)
    # Ruby tiene muchos métodos de manejo de strings
    pais.nombre.downcase != 'argentina'
  end
end

class Salieri < Periodista
  # Mixin: alternativa a herencia múltiple
  extend Forwardable
  attr_accessor :copiado

  def initialize(nombre, copiado)
    super(nombre)
    self.copiado = copiado
  end
  # Se delega al objeto de la izquierda cuando se mande 
  # el método de la derecha
  def_delegators :@copiado, :escribir_articulo
end
