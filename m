From: Eric Barton <eeb@sun.com>
Date: Wed, 04 Jun 2008 14:06:07 +0100
Subject: [Lustre-devel] FW: security: MGS connection
Message-ID: <018001c8c643$c0c14820$0281a8c0@ebpc>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Any comments on the security issue mentioned below?
 

-----Original Message-----
From: Peter.Braam@Sun.COM [mailto:Peter.Braam at Sun.COM] 
Sent: 04 June 2008 3:03 AM
To: Eric Barton
Cc: Eric.Mei at Sun.COM
Subject: Re: security: MGS connection


Please forward to lustre-devel?

On 6/3/08 5:27 AM, "Eric Barton" <eeb@sun.com> wrote:

> Peter,
> 
> I understand from Eric Mei that the connection to the MGS
> to obtain the filesystem configuration (including security) is
> itself never secured.  This seems like a defect to me.  Do you
> agree?  

Yes, but it needs to be secured with a static authentication associated with
the system, not with a particular user.  I don't know exactly how this
works, but it will be similar in spirit to a srvtab file that authenticates
a server to the KDC.

> 
> I'm no expert, so I don't know whether generic node security
> configuration could/should be consulted to determine how to secure
> this initial MGS connection.  If not, do you think that allowing
> it to be specified in the lustre mount options is a good/sufficient
> solution?

Yes, like a pointer to a cookie file or similar.

Thanks for catching this.

Peter

>  It would be bad to give the impression the whole mount
> was secured if only the MGS connection was...
> 
>     Cheers,
>               Eric
> 
