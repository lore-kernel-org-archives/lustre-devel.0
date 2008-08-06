From: Peter Braam <Peter.Braam@Sun.COM>
Date: Tue, 05 Aug 2008 20:32:07 -0600
Subject: [Lustre-devel] security: rpc message vs bulk data
In-Reply-To: <48989821.3090904@sun.com>
Message-ID: <C4BE6947.54D4%peter.braam@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi

Eric - can you add this detail to the presentation about the security
architecture?


On 8/5/08 12:12 PM, "Eric Mei" <Eric.Mei@Sun.COM> wrote:

> Hi,
> 
> Currently we use different security transformation: on RPC message we
> use gssapi/kerberos; on bulk data we use separate hash + cipher
> mechanism. And to some extend the 2 parts can be configured
> independently. For example, you can use "krb5p" on RPC message while use
> some light-weight hash/cipher on bulk data for performance or whatever
> reasons.

We should not use KRB/GSS for bulk data encryption, see below.

> 
> Now we're thinking about using gssapi for both RPC and bulk data. But
> this way we won't be able to configure them separately. What we're not
> sure is: is it necessary to be able to set different security level for
> RPC message and bulk data?

Yes two policies are good to have. Eventually file systems will store data
encrypted. It would not be a good idea to have encrypt twice - we want to
ask the client to encrypt the data, send it over the wire and store on disk
without decrypting.


> 
> Thanks!
