package org.lit.twopic;


import com.hp.hpl.jena.ontology.OntClass;
import com.hp.hpl.jena.ontology.OntModel;
import com.hp.hpl.jena.ontology.OntModelSpec;
import com.hp.hpl.jena.rdf.model.ModelFactory;
import com.hp.hpl.jena.util.PrintUtil;
import com.hp.hpl.jena.util.iterator.ExtendedIterator;

import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreeNode;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.net.MalformedURLException;
import java.net.URL;


/**
 * @author Chris Hokamp
 */
public class ClassHierarchy {

    DefaultTreeModel hierarchy;
    //URL url;
    String url;
    /**
     *  - the path to the DBpedia ontology RDF dump
     */

    public ClassHierarchy () throws FileNotFoundException {
          File f = new File("/home/chris/Downloads/dbpedia_data/owl/dbpedia_3.7.owl");
          //url = "/home/chris/Downloads/dbpedia_data/owl/dbpedia_3.7.owl";
          InputStream input = new FileInputStream(f);


          createTree(input);
    }

    //Create the tree from the rdf file
    //TODO: return DefaultTreeModel
    private void createTree (InputStream in) {

        //from docs: transitive class-hierarchy inference (trying different constants until the desired behavior is achieved)
        OntModel m = ModelFactory.createOntologyModel(OntModelSpec.OWL_DL_MEM_RULE_INF);

        m.read(in, null);

        //create a treeNode for each class



        //use getObjectProperty to return the value of "isSubclassOf")


        ExtendedIterator<OntClass> i = m.listClasses();
        //TEST
        while (i.hasNext()) {
            OntClass c = i.next();
            System.out.println("testing jena... LOCALNAME: " + c.getLocalName() + " URI: " + c.getURI());   // + " SUPERCLASS: " + c.getSuperClass().getURI()
            //TODO: test this more - currently listing only the direct super classes
            ExtendedIterator<OntClass> superClasses = c.listSuperClasses(true);
            int index = 0;
            while (superClasses.hasNext()) {
                System.out.println("SUPERCLASS "+ index +" = " + superClasses.next().getURI());
                index++;
            }
            //PrintUtil.print(c.l);
            //String classname = c
        }

        //END TEST
    }

}
