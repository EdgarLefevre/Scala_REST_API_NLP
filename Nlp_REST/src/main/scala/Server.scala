import cats.effect.{Effect, IO}
import fs2.StreamApp
import io.circe._
import io.circe.generic.auto._
import org.http4s.HttpService
import org.http4s.circe._
import org.http4s.dsl.Http4sDsl
import org.http4s.server.blaze.BlazeBuilder

import scala.concurrent.ExecutionContext
import scala.language.higherKinds


object Server extends StreamApp[IO] {

    import scala.concurrent.ExecutionContext.Implicits.global

    override def stream (args: List[String], requestShutdown: IO[Unit]): fs2.Stream[IO, StreamApp.ExitCode] = ServerStream.stream[IO]
}

object ServerStream {

    def textService[F[_] : Effect]: HttpService[F] = new TextService[F].service

    def graphService[F[_] : Effect]: HttpService[F] = new GraphService[F].service

    def stream[F[_] : Effect] (implicit executionContext: ExecutionContext): fs2.Stream[F, StreamApp.ExitCode] = {
        BlazeBuilder[F]
                .bindHttp(9000, "localhost")
                .mountService(textService, "/")
                .mountService(graphService, "/graph")
                .serve
    }
}


class TextService[F[_] : Effect] extends Http4sDsl[F] {
    implicit def circeJsonDecoder[A] (implicit decoder: Decoder[A]) = jsonOf[F, A]

    implicit def circeJsonEncoder[A] (implicit encoder: Encoder[A]) = jsonEncoderOf[F, A]

    case class Message (text: String)
    case class Fichiers (files: List[String])

    val service: HttpService[F] = HttpService[F] {
        case GET -> Root =>
            Ok(Fichiers(EventSourcing.listFolder("../Utils/text/")))

        case req@POST -> Root =>
            case class File(name : String, text: String)
            req.decode[File] {
                t => {
                    println(t.name)
                    EventSourcing.writeFile(t.name, t.text, "../Utils/text/")
                    Ok(Message("File " + t.name + " uploaded in text folder"))
                }
            }
    }
}

class GraphService[F[_] : Effect] extends Http4sDsl[F] {
    implicit def circeJsonDecoder[A] (implicit decoder: Decoder[A]) = jsonOf[F, A]

    implicit def circeJsonEncoder[A] (implicit encoder: Encoder[A]) = jsonEncoderOf[F, A]

    case class Message (text: String)
    case class Fichiers (files: List[String])
    case class Lieux (ESN : List[String])

    val service: HttpService[F] = HttpService[F] {
        case GET -> Root =>
            Ok(Fichiers(EventSourcing.listFolder("../Utils/graphs/")))

        case req@POST -> Root =>
            case class File(name : String, text: String)
            req.decode[File] {
                t => {
                    println(t.name)
                    EventSourcing.writeFile(t.name, t.text, "../Utils/text/")
                    Ok(Message("File " + t.name + " uploaded in graphs folder."))
                }
            }

        case GET -> Root / graph_name / txt_name =>
            EventSourcing.process(graph_name, txt_name)
            val res = EventSourcing.reqSparql()
            EventSourcing.rmTmp()
            Ok(Lieux(res))
    }

}



