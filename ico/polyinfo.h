/* polyinfo.h
 * This is the description of one polyhedron file
 */

#define MAXVERTS 120
	/* great rhombicosidodecahedron has 120 vertices */
#define MAXNV MAXVERTS
#define MAXFACES 30
	/* (hexakis icosahedron has 120 faces) */
#define MAXEDGES 180
	/* great rhombicosidodecahedron has 180 edges */
#define MAXEDGESPERPOLY 20

/* structure of the include files which define the polyhedra */
typedef struct {
	const char *longname;	/* long name of object */
	int uid;
	int numverts;		/* number of vertices */
	int numedges;		/* number of edges */
	int numfaces;		/* number of faces */
	const GLfloat verts[MAXVERTS*3];	/* the vertices */
	const GLubyte f[MAXEDGES*2+MAXFACES];	/* the faces */
} Polyinfo;

/* end */
