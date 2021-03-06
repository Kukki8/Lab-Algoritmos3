import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedList;
import java.util.NoSuchElementException;

public class GrafoNoDirigido implements Grafo {
	/*Atributos de la clase GrafoNoDirigido
	 * Grafo: Lista de lista de vertices que es la representacion de la lista de adyacencia del grafo
	 * Arista: lista de arista que es la lista de todas las arista que posee el grafo
	 */
	LinkedList<LinkedList<Vertice>> Grafo;
	LinkedList<Arista> Aristas;
	
	public void CrearGrafoNoDirigido() {
		Grafo=new LinkedList<LinkedList<Vertice>>();
		Aristas=new LinkedList<Arista>();
	}
	
	public Grafo crearGrafoNoDirigido(){
		return new GrafoNoDirigido();
	}
	// Agrega una Arista la lista de Aristas si la Arista no se encuentra y devuelve true,
	//En otro caso devuelve false.
	public boolean agregarArista(Arista a) {
		for(Arista e:Aristas) {
			if(e.obtenerExtremo1().obtenerId()==a.obtenerExtremo1().obtenerId()&&e.obtenerExtremo2().obtenerId()==a.obtenerExtremo2().obtenerId( )) {
				return false;
			}
		}	
		Aristas.add(a);
		boolean Existe1=false;
		boolean Existe2=false;
		Vertice vertice1=a.obtenerExtremo1();
		Vertice vertice2=a.obtenerExtremo2();
		for(int i=0;i<Grafo.size();i++) {
			if(Grafo.get(i).get(0)==vertice1) {
				Grafo.get(i).add(vertice2);
				Existe1=true;
			}
		
		}
		for(int j=0;j<Grafo.size();j++) {
			if(Grafo.get(j).get(0)==vertice2) {
				Grafo.get(j).add(vertice1);
				Existe2=true;
			}
		}
		if(Existe1==false) {
			LinkedList<Vertice> nuevovertice=new LinkedList<Vertice>();
			nuevovertice.add(vertice1);
			Grafo.add(nuevovertice);
			Grafo.get(Grafo.size()-1).add(vertice2);
			
		}
		if(Existe2==false) {
			LinkedList<Vertice> nuevovertice=new LinkedList<Vertice>();
			nuevovertice.add(vertice2);
			Grafo.add(nuevovertice);
			Grafo.get(Grafo.size()-1).add(vertice1);	
		}
		return true;
	}
	/*
	 * Si no existe un arco del tipo tipo entre u y v, crea una nueva aristay la agrega en el grafo. Retorna true
	 *en caso en que la inserci@n se lleva a cabo, false en contrario.
	
	 */
	public boolean agregarArista(String u, String v, int tipo, double peso) {
	
		if(!estaArista(u,v,tipo)) {
			if(estaVertice(u)&& estaVertice(v)) {
				Vertice nuevov1 = obtenerVertice(u);
            	Vertice nuevov2 = obtenerVertice(v);
				Arista nuevaArista=new Arista(peso,tipo,nuevov1,nuevov2);
			Aristas.add(nuevaArista);
			for(int i=0;i<Grafo.size();i++) {
				if(Grafo.get(i).get(0)==nuevov1) {
					Grafo.get(i).add(nuevov2);
				}
				if(Grafo.get(i).get(0)==nuevov2) {
					Grafo.get(i).add(nuevov1);
				}
			}
		return true;
			}
		}
		return false;
	}
		 public Vertice obtenerVertice(String name){

		        if(estaVertice(name)){
		            for(LinkedList<Vertice> v : Grafo){
		                if(v.get(0).obtenerNombre().equals(name) ){
		                    return v.get(0);
		                }
		            }
		        }else{
		            System.out.println("No existe un vertice en el grafo llamado " + name);
		        }
		        return null;

		    }
	/*Elimina la arista que es pasada como parametro. Se retorna true en caso que se haya
	eliminado la arista del grafo y false en caso de que no exista una arista con ese identificador en el
	grafo
	*/
	public boolean eliminarArista(Arista a) {
		boolean Existe=false;
		Vertice v1=a.obtenerExtremo1();
		Vertice v2=a.obtenerExtremo2();
		for(int i=0;i<Aristas.size();i++) {
			if(Aristas.get(i).obtenerExtremo1()==a.obtenerExtremo1() && Aristas.get(i).obtenerExtremo2()==a.obtenerExtremo2()) {
				Aristas.remove(i);
				Existe=true;
			}
		}
		if(Existe==true) {
			for(int i=0;i<Grafo.size();i++) {
				if(Grafo.get(i).get(0).obtenerId()==v1.obtenerId()) {
					for(int j=0;j<Grafo.get(i).size();j++) {
						if(Grafo.get(i).get(j).obtenerId()==v2.obtenerId()) {
							Grafo.get(i).remove(j);
						}
					}
				}
				if(Grafo.get(i).get(0).obtenerId()==v2.obtenerId()) {
					for(int j=0;j<Grafo.get(i).size();j++) {
						if(Grafo.get(i).get(j).obtenerId()==v1.obtenerId()) {
							Grafo.get(i).remove(j);
						}
					}
				}
			}
		}
		return Existe;
	}
	/*Devuelve la arista que es pasada como parametro. En caso de que no exista ninguna arista , se lanza la excepci@n NoSuchElementException.
	*/
	public Lado obtenerArista(Arista a) {
		for(Arista e:Aristas) {
			if(e.obtenerExtremo1().obtenerId()==a.obtenerExtremo1().obtenerId() && e.obtenerExtremo2().obtenerId()==a.obtenerExtremo2().obtenerId()&& e.obtenerPeso()==a.obtenerPeso()&& e.obtenerTipo()==a.obtenerTipo()) {
				return e;
			}
		}
		throw new NoSuchElementException("Esta Arsita no existe en el grafo");
	}
	/*
	 * Determina si una Arista pertenece a un grafo. La entrada son los identificadores de los v@rtices que son
	*los extremos del lado y el tipo de ese Arista.
	 */
	public boolean estaArista(String u, String v, int tipo) {
		 if(estaVertice(u) && estaVertice(v)){
	            for(Arista b : Aristas){
	                if(b.obtenerExtremo1().obtenerNombre() == u && b.obtenerExtremo2().obtenerNombre() == v && b.obtenerTipo() == tipo){
	                    return true;
	                }
	            }
	        }else if(!estaVertice(u) && estaVertice(v)){
	            System.out.println("No se puede agregar el arco porque el vertice " + u + " no existe.");
	            return false;

	        }else if(estaVertice(u) && !estaVertice(v)){
	            System.out.println("No se puede agregar el arco porque el vertice " + v + " no existe.");
	            return false;

	        }else if(!estaVertice(u) && !estaVertice(v)){
	            System.out.println("No se puede agregar el arco porque ninguno de los vertices existe." );
	            return false;  
	        }
	        return false;
	    }
	/*
	 * Determina si una Arista pertenece a un grafo. La entrada son los identificadores de los v@rtices que son
	*los extremos del lado y el tipo de ese Arista.
	 */
	public boolean estaArista(int u, int v, int tipo) {
		int id1,id2;
		id1=u;
		id2=v;
		for(Arista e:Aristas){
			if(e.obtenerExtremo1().obtenerId()==id1 && e.obtenerExtremo2().obtenerId()==id2) {
				return true;
			}
			else {
			
			}
		}
		return false;	
	}
	/*
	 * determina se el vertice pertenece al grafo o no en caso de pertenercer retorna True en otro caso false.
	 */
	  public boolean estaVertice(String nombre){
	        for(LinkedList<Vertice> v : Grafo){
	            if(v.get(0).obtenerNombre().equals(nombre) ){
	                return true;
	            }
	        }
	        System.out.println("No existe un vertice en el grafo llamado " +nombre);
	        return false;
	    }
	
	//#############################################################################
	@Override
	public boolean cargarGrafo(String Archivo) throws IOException {
		try {
		BufferedReader Lector = new BufferedReader(new FileReader(Archivo));
		int n,m,id,tipo;
		boolean Exito=false;
		String u,v;
		double x,y,peso;
		String nombre;
		String[] lineasinespacio;
		String linea=Lector.readLine(); //linea 1
		linea=Lector.readLine(); //linea2
		n=Integer.parseInt(linea);
		linea=Lector.readLine();//linea3
		m=Integer.parseInt(linea);
		
		for(int i=0;i<n;i++) {
			linea=Lector.readLine();//linea 4,5....n
			lineasinespacio=linea.split(" ");
			
			if(lineasinespacio.length==5) {	
				id=Integer.parseInt(lineasinespacio[0]);
				nombre=lineasinespacio[1];
				x=Double.parseDouble(lineasinespacio[2]);
				y=Double.parseDouble(lineasinespacio[3]);
				peso=Double.parseDouble(lineasinespacio[4]);
				agregarVertice(id,nombre,x,y,peso);
			}
			else {
				throw new IllegalArgumentException(" No es una linea de vertices valida");
			}
		}
		for(int j=0;j<m;j++) {
			linea=Lector.readLine(); //empieza las lineas de las aristas
			lineasinespacio=linea.split(" ");
			if(lineasinespacio.length==4) {	
				u=lineasinespacio[0];
				v=lineasinespacio[1];
				tipo=Integer.parseInt(lineasinespacio[2]);
				peso=Double.parseDouble(lineasinespacio[3]);
				agregarArista(u,v,tipo,peso);
				
			}
			else {
				throw new IllegalArgumentException("No es una linea de Aristas valida"); 
			}
			
		}
		return true;
		}catch(IOException e) {
					return false;
			}
		
	
		
	}

	@Override
	public int numeroDeVertices() {
		
		return Grafo.size();
	}

	@Override
	public int numeroDeLados() {
	
		return Aristas.size();
	}

	@Override
	public boolean agregarVertice(Vertice v) {
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==v.obtenerId()) {
				return false;
			}
		
		}
		LinkedList<Vertice> nuevovertice=new LinkedList<Vertice>();
		nuevovertice.add(v);
		Grafo.add(nuevovertice);
		return true;
	}

	@Override
	public boolean agregarVertice(int id, String nombre, double x, double y, double p) {
		Vertice v=new Vertice(id,nombre,x,y,p);
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==v.obtenerId()) {
				return false;
			}
		
		}
		LinkedList<Vertice> nuevovertice=new LinkedList<Vertice>();
		nuevovertice.add(v);
		Grafo.add(nuevovertice);
		return true;
	}

	

	@Override
	public Vertice obtenerVertice(int id) {
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==id) {
				return e.get(0);
			}
		}
		
		throw new NoSuchElementException("Este Vertice no existe en el grafo");
	}

	@Override
	public boolean estaVertice(int id) {
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==id) {
				return true;
			}
		}
		return false;
	}

	@Override
	public boolean eliminarVertice(int id) {
		boolean existe=estaVertice(id);
		if(existe==true) {
			for(int i=0;i<Grafo.size();i++) {
				if(Grafo.get(i).get(0).obtenerId()==id) {
					Grafo.remove(i);
				}
			}
			for(LinkedList<Vertice> e:Grafo) {
				for(int j=1;j<e.size();j++) {
					if(e.get(j).obtenerId()==id) {
						e.remove(j);
					}
				}
			}
			for(int i=0;i<Aristas.size();i++) {
				if(Aristas.get(i).obtenerExtremo1().obtenerId()==id || Aristas.get(i).obtenerExtremo2().obtenerId()==id) {
					Aristas.remove(i);
				}
			}
			return true;
		}
		else {
			return false;
		}
	}

	@Override
	public LinkedList<Integer> vertices() {
		LinkedList<Integer> listadevertices=new LinkedList<Integer>();
		for(LinkedList<Vertice> e:Grafo) {
			listadevertices.add(e.get(0).obtenerId());
		}
		return listadevertices;
	}

	@Override
	public LinkedList<Lado> lados() {
		LinkedList<Lado> Lados=new LinkedList<Lado>();
		for (Arista e:Aristas) {
			Lados.add(e);
		}
		return Lados;
	}

	@Override
	public int grado(int id) {
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==id) {
				return e.size()-1;
			}
		}
		
		throw new NoSuchElementException("Este Vertice no existe en el grafo");
	}

	@Override
	public LinkedList<Vertice> adyacentes(int id) {
		LinkedList<Vertice> adyaceentes=new LinkedList<Vertice>();
		Vertice v=null;
		for(LinkedList<Vertice> e:Grafo) {
			if(e.get(0).obtenerId()==id) {
				v=e.get(0);
				break;
			}
		}
		for(int i=0;i<Grafo.size();i++) {
		
			if(Grafo.get(i).get(0).obtenerId()==v.obtenerId()) {
				for(int j=1;j<Grafo.get(i).size();j++) {
					adyaceentes.add(Grafo.get(i).get(j));
					
				}
				return adyaceentes;
			}
		}
		throw new NoSuchElementException("Este Vertice no existe en el grafo");
	}

	@Override
	public LinkedList<Lado> incidentes(int id) {
		LinkedList<Lado> ladosincidentes=new LinkedList<Lado>();
		Vertice vertice1=null;
		boolean Existe=estaVertice(id);
		if(Existe==true) {
			for(LinkedList<Vertice> j:Grafo) {
				if(j.get(0).obtenerId()==id) {
					vertice1=j.get(0);
					break;
				}
			}
			for(Arista e:Aristas) {
				if(e.incide(vertice1)) {
					ladosincidentes.add(e);
			
				}
			}
				
		
		}
		else {
			throw new NoSuchElementException("Este Vertice no existe en el grafo");
		}
		return ladosincidentes;
		
	
	}

	@Override
	public Grafo clonar() {

        GrafoNoDirigido grafoClonado = new GrafoNoDirigido();
        for(LinkedList<Vertice> v : Grafo){
            Vertice vRepresen = v.get(0);
            grafoClonado.agregarVertice(vRepresen.obtenerId(), vRepresen.obtenerNombre(), vRepresen.obtenerX(), vRepresen.obtenerY(),vRepresen.obtenerPeso());
        }
        
        for(Arista a: Aristas){
            grafoClonado.agregarArista(a.obtenerExtremo1().obtenerNombre(), a.obtenerExtremo2().obtenerNombre(), a.obtenerTipo(), a.obtenerPeso());
        }
        return grafoClonado;
    }
	
	public String toString() {
		   String info = "";

	        for(int i=0;i<Grafo.size();i++){
	            	info = info+Grafo.get(i).get(0).obtenerNombre() + " -----> ";

	                for(int j=1;j<Grafo.get(i).size();j++){
	                    info=info+Grafo.get(i).get(j).obtenerNombre() + " ";
	                }
	                info=info+"\n";
	               
	        }
	        info=info+"\n";
	        
	       
	        	info=info+"Arcos:\n";
	        	info=info+"\n";
	                info += "Info de las Arista: " +"\n";
	                for(int j=0;j<Aristas.size();j++) {
	                info+="Arista "+ j +":"+"\n"+Aristas.get(j).toString()+"\n";
	                info=info+"\n";
	                }
	            
	        
	        return info;
	}
}

