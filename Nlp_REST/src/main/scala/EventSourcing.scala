import java.io.{File, PrintWriter}

import scala.sys.process._

object EventSourcing {

    def writeFile(name: String, text: String, url: String) = {
        val writer = new PrintWriter(new File(url + name))
        writer.write(text)
        writer.close()
    }


    def listFolder(path: String)={
        val d = new File(path)
        d.listFiles.filter(_.isFile).toList.map(_.toString.split("/").last)
    }

    def process(graph: String, text: String)={
        s"bash ../Utils/script/process.sh $graph $text".!
    }

    def parseFile() : List[String] ={
        (scala.xml.XML.loadFile("../Utils/text/concord.xml") \ "concordance" \"lieu").map(result=> result.text).toList
    }


    def reqSparql() = {
        parseFile().map(_.drop(1).replaceAll(" ", "%20")).map(s"bash ../Utils/script/query.sh " + _).map(_.!!).map(scala.xml.XML.loadString).map( _ \ "results" \ "result").map(result => result.text).filter(_.length>1)
    }

    def rmTmp()={
        "rm - rf../Utils/tmp".!
    }
}

