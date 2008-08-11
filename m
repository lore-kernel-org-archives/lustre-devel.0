From: Eric Mei <Eric.Mei@Sun.COM>
Date: Mon, 11 Aug 2008 13:51:48 -0600
Subject: [Lustre-devel] Security issues
In-Reply-To: <C4C5F044.6C46%peter.braam@sun.com>
References: <C4C5F044.6C46%peter.braam@sun.com>
Message-ID: <48A09854.8010401@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Peter Braam wrote:
>>> You do need to sign it and encrypt it - for multiple purposes, to secure the
>>> wire transaction and for storage on the server.
>> Sorry I'm still a little confused. To be exactly clear, do you mean: In
>> the future we'll use NASD-style protocol to secure the bulk data's wire
>> transfer & storage on server; and for now we can simply leave the bulk
>> data unprotected?
> 
> No you need to be able to encrypt it.
> 
> I'm just stating that if you the current solution (which gives privacy using
> GSS between client and OSS iirc) is going to be changed, then please change
> it in the correct way to accommodate re-using checksums and re-using the
> encrypted data for storage.  Doing either of these things twice is
> pointless.
> 
> Probably there should be options not to do so as part of the configuration.

Peter, Thanks for clarifying this! Yes that's what we're thinking.

-- 
Eric
