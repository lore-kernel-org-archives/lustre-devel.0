From: Danny Sternkopf <dsternkopf@hpce.nec.com>
Date: Fri, 26 Oct 2007 11:24:34 +0200
Subject: [Lustre-devel] Lustre - HA: lc_hb bug
Message-ID: <4721B252.1010808@hpce.nec.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

If lustre_config configures more than one failover pair the haresource
will be wrong except for the first failover pair.

lc_hb generates the haresource on the node running lustre_config in
/tmp/heartbeat/haresources.lustre. Later it will be copied to
haresources.lustre.<hostname>. For the 2nd failover pair the haresource
configuration will be added to haresources.lustre which is wrong. This
file should be cleared or removed before.

The following quick fix seems to help in line 436:
[root at dmds1 config]# sdiff -s /usr/sbin/lc_hb /usr/sbin/lc_hb.orig
        # Clean /tmp/heartbeat/haresources.lustre first       <
        rm -f ${HARES_LUSTRE}                                 <

I'am not 100% sure if it is okay for all cases.

Best regards,

Danny
