From: Nikita Danilov <Nikita.Danilov@Sun.COM>
Date: Sat, 12 Jul 2008 21:34:09 +0400
Subject: [Lustre-devel] Vector I/O api
In-Reply-To: <4878CFC8.3040203@sun.com>
References: <C49D8777.63F0%peter.braam@sun.com> <4878CFC8.3040203@sun.com>
Message-ID: <18552.60177.444426.24266@gargle.gargle.HOWL>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Tom.Wang writes:
 > 
 > Peter Braam wrote:
 > > Tom -
 > >
 > > In a recent call with CERN the request came up to construct a call 
 > > that can in parallel transfer an array of extents in a single file to 
 > > a list of buffers and vice-versa. 
 > > This call should be executed with read-ahead disabled, it will usually 
 > > be made when the user is well informed of the I/O that is about to 
 > > take place.
 > > Is this easy to get into the Lustre client (using our I/O library)? 
 > >  Do you have this already for MPI/IO use?
 > >
 > > Thanks.
 > >
 > > Peter
 > Hello, Peter
 > 
 > If you mean provide this list buffer read/write API in MPI by our 
 > library, it is easy.
 > Because MPI already provide such API, you can define proper 
 > discontingous buf_type
 > and file_type of these extents, and use (MPI_File_Write/read_all) to 
 > read/write these
 > buffers in one call . We only need disable read-ahead here. So it should 
 > be easy to
 > get into our I/O library.
 > 
 > But if you mean provide such API in llite, I am not sure it is easy. 
 > because it seems we

I think that if we are going to support this interface in a client, it
makes sense to implement it in CLIO. CLIO design of readv and writev
support allows upper layer (llite) to submit IO for multiple disjoint
file extents within single system call.

Nikita.
