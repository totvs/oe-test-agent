/**
 * ```OE Test Agent``` configuration.
 */
export declare class OEConfig {
    /**
     * Agent server host name or IP address.
     */
    host: string;
    /**
     * Agent server port number.
     */
    port: number;
    /**
     * OpenEdge installation directory.
     */
    dlcHome: string;
    /**
     * Profiler destination directory (with coverage information).
     */
    outDir: string;
    /**
     * PROPATH.
     */
    propath?: string[];
    /**
     * Initialization file (-ininame).
     */
    iniFile?: string;
    /**
     * Parameter file (-pf).
     */
    parameterFile?: string;
    /**
     * Startup program (full or parcial according to PROPATH).
     */
    startupFile?: string;
    /**
     * Startup program input parameters.
     */
    startupFileParams?: string[];
    /**
     * Input codepage.
     */
    inputCodepage?: string | undefined;
}
//# sourceMappingURL=OEConfig.d.ts.map