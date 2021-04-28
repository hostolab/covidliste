import React from "react";
import { QueryClient, QueryClientProvider } from "react-query";
import { camelCaseDeep } from "components/shared/casing";

const queryClient = new QueryClient();

export const RootWrapper = (RootComponent) => (propsFromRails) => (
  <QueryClientProvider client={queryClient}>
    <RootComponent {...camelCaseDeep(propsFromRails)} />
  </QueryClientProvider>
);
