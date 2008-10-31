From: Josephine Palencia <josephin@psc.edu>
Date: Fri, 31 Oct 2008 00:54:06 -0400 (EDT)
Subject: [Lustre-devel] Interoperability between Lustre 1.9.50 and 1.9.80?
Message-ID: <Pine.LNX.4.64.0810310042430.4907@pscuxa.psc.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Hi,

NB: Kerberos cross-realm authentication (testing) enabled

Mounting of lustre-1.9.50 lustre filesystem by a client built 
with lustre-1.9.5 produces the following error below:

> > Lustre: Added LNI 198.202.115.111 at tcp [8/256]
> > Lustre: Accept secure, port 988
> > Lustre: OBD class driver, http://www.lustre.org/
> > Lustre:         Lustre Version: 1.9.80
> > Lustre:         Build Version:
> >
> 1.9.80-19691231160000-PRISTINE-.usr.src.redhat.BUILD.kernel-lustre-2.6
> > .1 8.linux-2.6.18.x86_64-2.6.18-92.1.10.el5_lustre.1.9.80
> > Lustre: Lustre LU module (ffffffff88506740).
> > Lustre: 3586:0:(sec.c:1340:sptlrpc_import_sec_adapt()) import
> > ffff8104264a7000 (MGC128.182.112.70 at tcp->MGC128.182.112.70 at tcp_0)
> > netid
> > 20000: select initial flavor (null, null/null)
> > LustreError: 3620:0:(pack_generic.c:391:lustre_msg_buf_v2()) msg
> > ffff810425c37480 buffer[0] size 88 too small (required 152)
> > LustreError:
> > 3620:0:(pack_generic.c:577:lustre_unpack_ptlrpc_body_v2())
> > error unpacking ptlrpc body
> > LustreError: 3620:0:(pack_generic.c:1083:lustre_msg_get_status())
> > invalid msg ffff810425c37480: no ptlrpc body!
> > LustreError: 3620:0:(pack_generic.c:805:lustre_msg_get_flags())
> > invalid msg ffff810425c37480: no ptlrpc body!
> > LustreError: 3620:0:(client.c:291:unpack_reply()) @@@ unpack ptlrpc
> > body
> > failed: -14  req at ffff8104264b0800 x1284919012622337/t0(0)
> > o250->MGS at MGC128.182.112.70@tcp_0:26/25 lens 368/200 e 0 to 11 dl
> > 1225394272 ref 1 fl Rpc:R/0/0 rc 0/-22
> > LustreError: 3620:0:(layout.c:1410:__req_capsule_get()) @@@ Wrong
> > buffer for field `cdata' (1 of 2) in format `MDS_CONNECT':
> 72 vs. 200
> > (server)  req at ffff8104264b0800 x1284919012622337/t0(0)
> > o250->MGS at MGC128.182.112.70@tcp_0:26/25 lens 368/200 e 0 to 11 dl
> > 1225394272 ref 1 fl Interpret:R/0/0 rc -71/-22
> > LustreError: 3586:0:(client.c:850:ptlrpc_import_delay_req()) @@@
> > IMP_INVALID  req at ffff8104264b0400 x1284919012622339/t0(0)
> > o501->MGS at MGC128.182.112.70@tcp_0:26/25 lens 264/240 e 0 to 11 dl 0
> > o501->ref
> > 1 fl Rpc:/0/ffffffff rc 0/-1
> > LustreError: 15c-8: MGC128.182.112.70 at tcp: The
> configuration from log
> > 'testfs-client' failed (-108). This may be the result of
> communication
> > errors between this node and the MGS, a bad configuration, or other
> > errors. See the syslog for more information.
> > LustreError: 3586:0:(llite_lib.c:1079:ll_fill_super()) Unable to
> > process
> > log: -108
> > Lustre: client ffff81043be0c800 umount complete
> > LustreError: 3586:0:(obd_mount.c:1982:lustre_fill_super())
> Unable to
> > mount  (-108)


Error seems to point to the size of ptlrpc_body which is 152byes on 2.0 
and 88bytes in 1.8. However both lustre versions are minor versions of the 
major release..?

Short of me rebuilding/upgrading to lustre 1.9.80 or the client site 
downgrading to 1.9.50, any suggested work-arounds or something I am 
missing?


THank you,
Josephine
