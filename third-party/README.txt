Data of coordinates of all regular-faced convex polyhedra

                                                           Jun. 22, 1994

                           Kobayasi, Mituo
                           Department of Computer Science
                              and Information Mathematics
                           University of Electro-Communications
                           1-5-1, Chofugaoka, Chofu-shi, Tokyo 182, JAPAN

                           Suzuki, Takuzi
                           Department of Museum Science
                           National Museum of Japanese History
                           117, Jyonai-cho, Sakura-shi, Chiba 285, JAPAN
                           E-mail: suzuki@alp0.cs.uec.ac.jp
                                   suz-tak@tansei.cc.u-tokyo.ac.jp

1. Introduction

  Regular polyhedron, semiregular polyhedron, prism, and antiprism are
kinds of convex polyhedra with regular faces. Viktor A. Zalgaller
proved that the number of kinds of other convex polyhedra with regular
faces is 92[1].  They have beautiful exterior, but unfortunately not
familiar.

  We devised a set of algorithms to calculate coordinates of all vertices
of a given convex polyhedron with regular faces[2].

  Presented here is the data of adjacency list and coordinates of
vertices of every regular-faced convex polyhedron.

Notes: 
  [1] Zalgaller,V.A.: Convex Polyhedra with Regular Faces, Consultants
      Bureau, 1969. (Zalgaller,B.A.: Vypuklye Mnogogranniki c Pravil'nymi
      Granyami, Nauka Press, 1966.)
  [2] Kobayasi,M. and Suzuki,T.: Calculation of Coordinates of Vertices
      of All Convex Polyhedra with Regular Faces (written in Japanese),
      Bulletin of The University of Electro-Communications, Vol.5, 
      No.2, pp.147-184(1992).


2. Data Files

  Data files of coordinates exist in the directory `data/.'

  One file contains the data of one polyhedron. The following list
shows file names of each polyhedron. The correspondence of file names
and names of polyhedron is given in Table 1, Table 2, and Table 3,
which exist in the file `dname.tex.'

  The letter L and R respectively denote the left-hand and the 
right-hand of the polyhedron.

Regular polyhedra: r01, r02, r03, r04, r05.
(r02 = a03, r03 = p04)

Semiregular polyhedra:
s01, s02, s03, s04, s05, s06, s07, s08, s09, s10,
s11, s12L, s12R, s13L, s13R.
(n37 is a so-called 'Mirror's polyhedron,' and sometimes classified as
a kind of semiregular polyhedron.)

Prism: p03, p04, p05, p06, p07, p08, p09, p10.

Antiprisms: a03, a04, a05, a06, a07, a08, a09, a10.

Other regular-faced convex polyhedra:
n01, n02, n03, n04, n05, n06, n07, n08, n09, n10, n11, n12, n13, n14,
n15, n16, n17, n18, n19, n20, n21, n22, n23, n24, n25, n26, n27, n28,
n29, n30, n31, n32, n33, n34, n35, n36, n37, n38, n39, n40, n41, n42,
n43, n44L, n44R, n45L, n45R, n46L, n46R, n47L, n47R, n48L, n48R, n49,
n50, n51, n52, n53, n54, n55, n56, n57, n58, n59, n60, n61, n62, n63,
n64, n65, n66, n67, n68, n69, n70, n71, n72, n73, n74, n75, n76, n77,
n78, n79, n80, n81, n82, n83, n84, n85, n86, n87, n88, n89, n90, n91,
n92.


3. The Data Format

  The data of one polyhedron consists of 4 parts:

    1. Adjacency list of vertices.
    2. List of faces around each vertices.
    3. List of vertices of each faces.
    4. Coordinates of each vertices.

  Every vertex and Every face is identified by a number. For n
vertices, the identifier runs from 1 to n. For m faces, the identifier
runs from 1 to m.

  Following is the data format of a polyhedron:

    # of vertices
    ID of vertex, # of adjacent vertices, ID list of adjacent vertices
    ...
    # of vertices
    ID of vertex, # of adjacent faces, ID list of adjacent faces
    ...
    # of faces
    ID of face, # of vertices of the face, ID list of vertices of the face
    ...
    # of vertices
    ID of vertex, X-coordinate, Y-coordinate, Z-coordinate
    ...


4. Hardcopy

  Hardcopy files of exterior of polyhedra are given in the directory
`hardcopy/.' The format is PBM.
