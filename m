From: Eric Barton <eeb@sun.com>
Date: Mon, 23 Feb 2009 17:56:24 +0300
Subject: [Lustre-devel] moving obd_fail_check to libcfs
In-Reply-To: <49A18841.7030200@cray.com>
References: <49A18841.7030200@cray.com>
Message-ID: <000101c995c6$e95ded80$bc19c880$@com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Seems a fine thing to do - lets see the patch...

    Cheers,
              Eric

> -----Original Message-----
> From: lustre-devel-bounces at lists.lustre.org [mailto:lustre-devel-bounces at lists.lustre.org] On Behalf Of Nic Henke
> Sent: 22 February 2009 5:16 PM
> To: lustre-devel at lists.lustre.org
> Subject: [Lustre-devel] moving obd_fail_check to libcfs
> 
> Would there be any objection to a patch that'd move the current
> obdclass-centric obd_fail_check and friends to libcfs ? I'd like to be
> able to use the same logic inside LNET and our new LND without
> replicating the code.
> 
> I'm thinking it would need to be renamed to CFS_FAIL_CHECK as well.
> 
> Thoughts or suggestions?
> 
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
