From: Eric Mei <Eric.Mei@Sun.COM>
Date: Tue, 05 Aug 2008 12:12:49 -0600
Subject: [Lustre-devel] security: rpc message vs bulk data
Message-ID: <48989821.3090904@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

Currently we use different security transformation: on RPC message we 
use gssapi/kerberos; on bulk data we use separate hash + cipher 
mechanism. And to some extend the 2 parts can be configured 
independently. For example, you can use "krb5p" on RPC message while use 
some light-weight hash/cipher on bulk data for performance or whatever 
reasons.

Now we're thinking about using gssapi for both RPC and bulk data. But 
this way we won't be able to configure them separately. What we're not 
sure is: is it necessary to be able to set different security level for 
RPC message and bulk data?

Thanks!
-- 
Eric
