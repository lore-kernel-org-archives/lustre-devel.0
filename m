From: DENIEL Philippe <philippe.deniel@cea.fr>
Date: Fri, 06 Apr 2012 15:44:43 +0200
Subject: [Lustre-devel] Who does setfsuid() work with quota in LUSTRE ?
Message-ID: <4F7EF34B.60006@cea.fr>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

I am developing a NFS Server (NFS-Ganesha, see 
http://nfs-ganesha.sf.net) in user space with a LUSTRE backend.
The daemon runs as root, but for NFS requesy processing, I use 
setfsuid() and setfsgid() (for setting "fs credentials") before 
operating on the LUSTRE backend, using jointly the liblustreapi and 
POSIX calls from the glibc. In fact, this approach works well as long as 
quotas are not concerned.
Inode quota works fine : if a user exceed inode hard limit, he got (via 
NFS)  a "Disk Quota exceeded" error. That's OK. Quotas on data behave on 
a stranger way : the written blocks are taken in account for increasing 
"used blocks" for that user, and a expiration date appear as the soft 
limite is passed, but the user can continue writing beyond the hard limit.
At the beginning, I had files opened with fsuid=0 and then written with 
fsuid=non-root, I thought the fd remember the user that created it. So I 
wrote this small program:

    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <sys/fsuid.h>
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <string.h>
    #include <errno.h>

    #define SIZE 10240
    #define MOI 500

    int main( int argc, char * argv[] )
    {
      char * buff = NULL ;
      int fd =0 ;

      buff = malloc( SIZE ) ;

      fd = open( argv[1], O_CREAT|O_RDWR, 0644 ) ;
      printf( "buff=%p, errno=%u\n", buff, errno ) ;

      printf( "fd = %d\n", fd ) ;

      setfsuid( MOI ) ;
      printf( "bytes written = %d, errno=%u\n", write( fd, buff, SIZE 
    ), errno ) ;

      printf( "fsync:%d errno=%u\n", fsync( fd ), errno ) ;
      printf( "close:%d errno=%u\n", close( fd ), errno )  ;
    }

If run as non-root user whose quota are exceeded (a user that should get 
EDQUOT on every write operation), I got this message:

    buff=0x1e22010, errno=0
    fd = 3
    bytes written = -1, errno=0
    fsync:-1 errno=122
    close:0 errno=122

That really makes sense (setfsuid has no effect here). I am just a bit 
surprised that write() set errno to 0 but writes nothing, letting 
fsync()/close() return EDQUOT(122)
Then I run the program as root, I saw that display:

    buff=0xee8010, errno=0
    fd = 3
    bytes written = 10240, errno=0
    fsync:0 errno=0
    close:0 errno=0

As you see, the IO was successful. At the same time,  "lfs quota -u 
<user> " showed that the counter of used block for that user incresased.
I then changed my program to have the setfsuid() called BEFORE the open 
is made. The test code was then looking like this:

    #include <unistd.h>
    #include <stdlib.h>
    #include <stdio.h>
    #include <sys/fsuid.h>
    #include <sys/types.h>
    #include <sys/stat.h>
    #include <fcntl.h>
    #include <string.h>
    #include <errno.h>

    #define SIZE 10240
    #define MOI 500

    int main( int argc, char * argv[] )
    {
      char * buff = NULL ;
      int fd =0 ;

      buff = malloc( SIZE ) ;

      *setfsuid( MOI ) ;*
      fd = open( argv[1], O_CREAT|O_RDWR, 0644 ) ;
      printf( "buff=%p, errno=%u\n", buff, errno ) ;

      printf( "fd = %d\n", fd ) ;
      printf( "bytes written = %d, errno=%u\n", write( fd, buff, SIZE 
    ), errno ) ;

      printf( "fsync:%d errno=%u\n", fsync( fd ), errno ) ;
      printf( "close:%d errno=%u\n", close( fd ), errno )  ;
    }

And I ran the same test on new files, both as root and non-root (user 
with uid=500). I got exactly the same message as above.
It seems like setfsuid() as lesser impact on block quota. This is really 
messy for my application.
Do you have any idea of what happened and/or what I could do to have 
write() returning EDQUOT after setfsuid() ?

I am currently using lustre-2-1-0 RPMS.

    Regards

       Philippe
